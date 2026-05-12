# Projeto GEB — Contexto para Claude Code

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
- Formato: `[{"imagem":"<nivel>/estrutura/UUID.jpg","titulo":"...","descricao":"...","icone":"<nivel>/estrutura/icones/UUID.png"}]`

### Pastas de constantes nos admins
```javascript
var PASTA_LAZER        = '<nivel>/estrutura';
var LAZER_PREFIX       = '<nivel>/estrutura/';
var LAZER_JSON_PASTA   = '<nivel>';
var LAZER_JSON_NOME    = 'estrutura.json';
var PASTA_LAZER_ICONES = '<nivel>/estrutura/icones';
var LAZER_ICONES_PREFIX = '<nivel>/estrutura/icones/';
```

### tituloMap — regra obrigatória
- Keys sempre em **lowercase** (`img.nome.toLowerCase()`)
- Checar com operador `in`: `(k in tituloMap) ? tituloMap[k] : def`
- UUID check: `if(/^[0-9a-f]{8}[-_ ]/i.test(t)) t = '';` — só no **título**, nunca no nome do arquivo
- Portal usa `'Espaço'` como fallback (não o nome do arquivo)

### Race condition — _lazerSeq (FIX APLICADO em todos os 4 admins)
O servidor Delphi renomeia arquivos uploaded para UUID. `carregarLazer()` é assíncrono e pode completar depois que o usuário já salvou, sobrescrevendo `_lazerItens` com dados obsoletos.

**Padrão correto obrigatório:**
```javascript
var _lazerItens = [], _lazerSeq = 0;

function carregarLazer(){
    var seq = ++_lazerSeq;
    fetch(...)
    .then(function(lista){
        if(seq !== _lazerSeq) return;  // ← aborta se stale
        _lazerItens = lista.map(...);
        renderLazerAdmin();
    })
    .catch(function(){ if(seq !== _lazerSeq) return; _lazerItens = []; renderLazerAdmin(); });
}

function _salvar(item, isNew){
    _lazerSeq++;              // ← invalida cargas em voo
    fecharModalLazer();
    if(isNew) _lazerItens.push(item);
    atualizarLazerJSON(); renderLazerAdmin();
    toast('...');
    carregarLazer();          // ← relança com JSON já atualizado
}
```

### Upload de ícone — list-before (FIX APLICADO)
O servidor retorna sucesso mas o nome do arquivo na resposta não é confiável. Para descobrir o UUID gerado pelo servidor, listar a pasta ANTES do upload e comparar com DEPOIS:
```javascript
function _uploadIcone(iconeAtual, cb){
    fetch('/listar?pasta=...&raw=1')
    .then(function(antesLista){
        var antesNomes = antesLista.map(function(x){ return x.nome; });
        // faz upload...
        .then(function(){
            fetch('/listar?pasta=...&raw=1')
            .then(function(lista){
                var novo = null;
                for(var i=0;i<lista.length;i++){
                    if(antesNomes.indexOf(lista[i].nome) < 0){ novo = lista[i].nome; break; }
                }
                cb(novo ? PREFIX + novo : iconeAtual || '');
            });
        });
    });
}
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

| Admin           | Status                                      |
|-----------------|---------------------------------------------|
| Educação Infantil | ✅ completo — estrutura + ícone + race fix |
| Fundamental I   | ✅ completo — estrutura + ícone + race fix  |
| Fundamental II  | ✅ completo — estrutura + ícone + race fix  |
| Anos Finais     | ✅ completo — estrutura + ícone + race fix  |
| Ensino Médio    | ⏳ pendente                                 |
| Pré-vestibular  | ⏳ pendente                                 |

---

## Branch ativa

`DevTiago_GEB` — remoto: `https://github.com/pedrotiago36/pedrotiago36.github.io.git`
