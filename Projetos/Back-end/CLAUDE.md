# Projeto GEB — Contexto para Claude Code

---

## Regras obrigatórias de comportamento

1. **Compilação Delphi** — Após cada alteração, informar claramente:
   - Se a mudança é só em HTML/JS/JSON: _"Não precisa compilar nada — basta atualizar as páginas no navegador."_
   - Se a mudança exige recompilação do servidor: _"Precisa compilar o projeto Delphi: `<nome do projeto>`."_

2. **Commits** — Nunca fazer commit sem o usuário pedir explicitamente. Só commitar após o usuário validar e solicitar.

3. **Idioma** — Sempre responder em português brasileiro. Traduzir tudo que for possível.

4. **Escopo** — Nunca fazer nada que não foi pedido. Sem refatorações extras, sem limpezas não solicitadas, sem "melhorias" por conta própria.

5. **Dúvidas** — Se algo estiver confuso ou ambíguo, perguntar antes de fazer qualquer coisa. Nunca assumir e agir.

---

## Visão geral
Sistema web para o Grupo Escolar Batista (GEB). Servidor Delphi (UniGUI) serve o HTML/JS a partir de pastas locais. O conteúdo é editado por um painel admin e consumido por páginas de portal. Não há framework JS — tudo é JS vanilla puro.

---

## Estrutura de pastas

```
D:\Projetos Batista\GEB\
├── Projetos\
│   ├── Back-end\                        ← repositório git principal
│   │   ├── admin\                       ← SOURCE dos admins (editar aqui)
│   │   └── prj\Win32\Debug\files\
│   │       └── admin\                   ← DEPLOY dos admins (copiar sempre)
│   └── Front-End\
│       └── prj\Win32\Debug\files\       ← SOURCE + DEPLOY do portal e JSONs
│           ├── *.html                   ← páginas do portal
│           ├── educInfantil\            ← JSON + imagens educação infantil
│           ├── fundI\                   ← JSON + imagens fundamental I
│           ├── fundII\                  ← JSON + imagens fundamental II
│           └── finais\                  ← JSON + imagens anos finais
```

## Workflow de deploy OBRIGATÓRIO

1. Editar source em `Back-end/admin/<arquivo>.html`
2. Copiar para `Back-end/prj/Win32/Debug/files/admin/<arquivo>.html`
3. Para páginas do portal, editar diretamente em `Front-End/prj/Win32/Debug/files/<arquivo>.html`
4. JSONs e imagens ficam em `Front-End/prj/Win32/Debug/files/<nivel>/`

```bash
cp "Back-end/admin/niveis-ensino-fundI.html" "Back-end/prj/Win32/Debug/files/admin/niveis-ensino-fundI.html"
```

---

## Arquivos por nível de ensino

| Nível           | Admin source                        | Portal                          |
|-----------------|-------------------------------------|---------------------------------|
| Educação Infantil | admin/niveis-ensino-infantil.html | Front-End/.../educInfantil.html |
| Fundamental I   | admin/niveis-ensino-fundI.html      | Front-End/.../fundI.html        |
| Fundamental II  | admin/niveis-ensino-fundII.html     | Front-End/.../fundII.html       |
| Anos Finais     | admin/niveis-ensino-finais.html     | Front-End/.../finais.html       |

---

## Padrão técnico — Nossa Estrutura (Lazer)

Cada nível de ensino tem uma seção "Nossa Estrutura" com cards de imagem + título + descrição + ícone opcional.

### JSONs de dados
- Localização: `Front-End/prj/Win32/Debug/files/<nivel>/estrutura.json`
- Formato: `[{"imagem":"<nivel>/estrutura/UUID.jpg","titulo":"...","descricao":"...","icone":"data:image/png;base64,..."}]`
- **O campo `icone` armazena um data URL base64** — NÃO um caminho de arquivo no servidor.

### Pastas de constantes nos admins
```javascript
var PASTA_LAZER        = '<nivel>/estrutura';
var LAZER_PREFIX       = '<nivel>/estrutura/';
var LAZER_JSON_PASTA   = '<nivel>';
var LAZER_JSON_NOME    = 'estrutura.json';
var PASTA_LAZER_ICONES = '<nivel>/estrutura/icones';   // declarado mas NÃO usado para upload
var LAZER_ICONES_PREFIX = '<nivel>/estrutura/icones/'; // só usado para deletar ícones antigos (path format)
```

### tituloMap — regra obrigatória
- Keys sempre em **lowercase** (`img.nome.toLowerCase()`)
- Checar com operador `in`: `(k in tituloMap) ? tituloMap[k] : def`
- UUID check: `if(/^[0-9a-f]{8}[-_ ]/i.test(t)) t = '';` — só no **título**, nunca no nome do arquivo
- Portal usa `'Espaço'` como fallback (não o nome do arquivo)

### Race condition — _lazerSeq (FIX APLICADO em todos os admins)
O servidor Delphi renomeia arquivos uploaded para UUID. `carregarLazer()` é assíncrono e pode completar depois que o usuário já salvou, sobrescrevendo `_lazerItens` com dados obsoletos.

**Padrão correto obrigatório:**
```javascript
var _lazerItens = [], _lazerSeq = 0;

function carregarLazer(){
    var seq = ++_lazerSeq;
    fetch('/files/'+LAZER_JSON_PASTA+'/'+LAZER_JSON_NOME+'?v='+Date.now())
    .then(function(r){return r.ok?r.json():[];}).catch(function(){return[];})
    .then(function(jsonEntries){
        var tituloMap={}, descMap={}, iconeMap={};
        if(Array.isArray(jsonEntries)){ jsonEntries.forEach(function(e){
            var nome=(e.imagem||'').split('/').pop().toLowerCase();
            tituloMap[nome]=e.titulo||''; descMap[nome]=e.descricao||''; iconeMap[nome]=e.icone||'';
        }); }
        return fetch('/listar?pasta='+encodeURIComponent(PASTA_LAZER)+'&raw=1')
        .then(function(r){return r.json();})
        .then(function(lista){
            if(seq !== _lazerSeq) return;  // ← aborta se stale
            _lazerItens = lista.map(function(img){
                var k=img.nome.toLowerCase();
                var def=img.nome.replace(/\.[^.]+$/,'').replace(/_/g,' ');
                var t=(k in tituloMap)?tituloMap[k]:def;
                if(/^[0-9a-f]{8}[-_ ]/i.test(t)) t='';
                return {nome:img.nome, titulo:t, descricao:descMap[k]||'', icone:iconeMap[k]||''};
            });
            document.getElementById('cnt-lazer').textContent=_lazerItens.length;
            renderLazerAdmin();
        });
    }).catch(function(){ if(seq!==_lazerSeq)return; _lazerItens=[]; renderLazerAdmin(); });
}
```

**`_salvar` — ATENÇÃO: NÃO chamar `carregarLazer()` dentro de `_salvar`.**
Motivo: o ícone é um data URL base64 guardado em memória. Se chamarmos `carregarLazer()` após salvar, há risco de o GET do JSON chegar antes do POST do save terminar no servidor, lendo o JSON antigo (sem ícone) e sobrescrevendo `_lazerItens`. O `_lazerSeq++` em `_salvar` já é suficiente para invalidar a carga do page-init.

```javascript
function atualizarLazerJSON(){
    var entries=_lazerItens.map(function(item){
        return {imagem:LAZER_PREFIX+item.nome, titulo:item.titulo, descricao:item.descricao||'', icone:item.icone||''};
    });
    var b64; try{b64=btoa(unescape(encodeURIComponent(JSON.stringify(entries))));}catch(e){return Promise.resolve();}
    return fetch('/salvar-texto',{method:'POST',headers:{'Content-Type':'application/json'},
        body:JSON.stringify({pasta:LAZER_JSON_PASTA,nome:LAZER_JSON_NOME,rawmode:'1',base64:b64})
    }).catch(function(){});
}

function _salvar(item, isNew){
    _lazerSeq++;              // ← invalida cargas em voo
    fecharModalLazer();
    if(isNew) _lazerItens.push(item);
    renderLazerAdmin();
    toast(isNew?'"'+item.titulo+'" adicionado! O portal atualiza em até 30 segundos.':'Alterações salvas!');
    atualizarLazerJSON();     // ← SEM .then(carregarLazer) — intencional
}
```

---

## Ícones da Nossa Estrutura — padrão base64 (FIX APLICADO em fundI)

### Por que base64 e não upload para o servidor
A abordagem anterior (upload para `<nivel>/estrutura/icones/`) falhava silenciosamente porque a subpasta `icones/` pode não existir no servidor Delphi, e o servidor não auto-cria subdiretórios. O upload retornava erro, o `.catch` chamava `cb('')`, e o item era salvo sem ícone.

**Solução adotada:** ler o arquivo de ícone como data URL (`FileReader.readAsDataURL`) e guardar o base64 diretamente no campo `icone` do JSON. Nenhuma pasta no servidor é necessária.

### `_uploadIcone` — padrão correto (admin)
```javascript
function _uploadIcone(iconeAtual, cb){
    if(_lazerIconeRemover){ cb(''); return; }
    if(!inpIcone.files||!inpIcone.files[0]){ cb(iconeAtual||''); return; }
    var fi=inpIcone.files[0];
    if(fi.size>307200){ toast('Ícone muito grande — máximo 300 KB',true); cb(iconeAtual||''); return; }
    lerArq(fi, function(src){ cb(src); });  // src = "data:image/png;base64,..."
}
```

### `renderLazerAdmin` — exibir ícone no card do admin
O ícone pode ser data URL ou caminho de arquivo (itens antigos). Verificar com `indexOf('data:')`:
```javascript
var iconeTag='';
if(item.icone){
    var _is = item.icone.indexOf('data:')===0
        ? item.icone
        : '/files/'+esc(item.icone)+'?v='+Date.now();
    iconeTag='<img src="'+_is+'" style="width:22px;height:22px;object-fit:contain;vertical-align:middle;margin-left:5px;" title="Ícone personalizado">';
}
```

### `editarLazer` — carregar preview do ícone existente
```javascript
if(item.icone){
    var _is = item.icone.indexOf('data:')===0
        ? item.icone
        : '/files/'+item.icone+'?v='+Date.now();
    document.getElementById('mLazerIconePreview').src = _is;
    document.getElementById('mLazerIconePreviewBox').style.display='block';
    document.getElementById('mLazerIconeLabel').textContent='Trocar Ícone (opcional)';
    document.getElementById('mLazerIconeRemoverBox').style.display='block';
}
```

### `excluirLazer` — deletar ícone do servidor só se for caminho (não data URL)
```javascript
function excluirLazer(nome){
    var _excItem=_lazerItens.filter(function(i){return i.nome===nome;})[0];
    var _excIcone=_excItem&&_excItem.icone?_excItem.icone:'';
    confirmar('Excluir este espaço?',nome,function(){
        fetch('/deletar',{...nome:nome,pasta:PASTA_LAZER...})
        .then(function(){
            // só tenta deletar do servidor se for caminho de arquivo (não data URL)
            if(_excIcone && _excIcone.indexOf('data:')!==0){
                var _ic=_excIcone.split('/').pop();
                fetch('/deletar',{...nome:_ic,pasta:PASTA_LAZER_ICONES...}).catch(function(){});
            }
            _lazerItens=_lazerItens.filter(function(i){return i.nome!==nome;});
            atualizarLazerJSON();
            document.getElementById('cnt-lazer').textContent=_lazerItens.length;
            renderLazerAdmin();
            toast('Espaço excluído!');
        })
        .catch(function(){ toast('Erro ao excluir',true); });
    });
}
```

---

## Ícones da Nossa Estrutura — portal

### Renderização do ícone no portal (`renderEstrutura`)
```javascript
var iconeHasImg = !!item.icone;
var icone = iconeHasImg
    ? '<img src="'+(item.icone.indexOf('data:')===0 ? item.icone : '/files/'+item.icone)+'" alt="" style="width:44px;height:44px;object-fit:contain;">'
    : icons[i % icons.length];  // emoji padrão: ['🏫','📚','⚽','🔬','💻','🎨','🏃','🎭','🌿','🎵']

// Quando há ícone personalizado: remove o círculo colorido do container
var iconeWrap = iconeHasImg
    ? '<div class="estrutura-item-icon" style="background:none;">'
    : '<div class="estrutura-item-icon">';

return '<div class="estrutura-item...">' +
       iconeWrap + icone + '</div>' + ...
```

**Regra visual:**
- **Sem ícone** → círculo dourado com emoji padrão (comportamento original)
- **Com ícone** → `background:none` no container, imagem 44×44px sem moldura colorida

---

## Padrão portal — Nossa Estrutura (slider + cards)

### Divisão de informação entre slider e cards (fundI e fundII)
- **Slider (foto passando)** → exibe a **descrição** sobreposta à imagem (fundo amarelo, `estrutura-slide-titulo`)
- **Card lateral (lista)** → exibe só o **título** (sem descrição)

Regra: o overlay do slider só renderiza se houver descrição; se não houver, a foto aparece limpa.

```javascript
// _estruturaHtml — slider mostra descrição
var desc = item.descricao || '';
return '<div class="estrutura-slide-item">' +
       '<img src="/files/' + item.imagem + '" ...>' +
       (desc ? '<div class="estrutura-slide-capa"><div class="estrutura-slide-titulo">' + desc + '</div></div>' : '') +
       '</div>';

// renderEstrutura — card lateral mostra só título
return '<div class="estrutura-item...">' +
       iconeWrap + icone + '</div>' +
       '<div><h4>' + titulo + '</h4></div></div>';
```

---

## Padrão portal — atualização de conteúdo

- **Poll a cada 30s**: galeria, estrutura, momentos, diferenciais, versículo
- **Carrega 1x ao entrar**: banner, proposta pedagógica
- Portal usa `init` escalonado com `setTimeout` para não sobrecarregar o servidor

---

## Regras JS obrigatórias

- **NUNCA usar `document.write()`** — trava o parser; usar `createElement/appendChild`
- **NUNCA deixar `||` sem operando direito** — SyntaxError mata todo o script block; sempre `||''`, `||0`, etc.
- **Sidebar admin**: usar `<div onclick>`, CSS simples sem `!important`, função `ir()` com `querySelectorAll`
- Se algo na navegação não funcionar → **verificar Console por SyntaxError primeiro**

---

## Comunicação Delphi → iframe (UniGUI JS Bridge)

Passar dados do Delphi para o iframe via `window.parent.AddJS(...)`.

---

## Estado atual dos admins (maio 2026)

| Admin             | Status                                                        |
|-------------------|---------------------------------------------------------------|
| Educação Infantil | ✅ estrutura + race fix — ⚠️ ícone base64 pendente           |
| Fundamental I     | ✅ completo — estrutura + ícone base64 + race fix             |
| Fundamental II    | ✅ completo — estrutura + ícone base64 + race fix             |
| Anos Finais       | ✅ estrutura + race fix — ⚠️ ícone base64 pendente           |
| Ensino Médio      | ⏳ pendente                                                   |
| Pré-vestibular    | ⏳ pendente                                                   |

---

## Branch ativa

`DevTiago_GEB` — remoto: `https://github.com/pedrotiago36/pedrotiago36.github.io.git`
