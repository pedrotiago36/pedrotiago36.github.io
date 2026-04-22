// ── BRIDGE (mesmo padrão fundI.html) ──
function carregarDados(pasta, cb) {
    var uni = null;
    try { uni = window.parent.parent; } catch(e) {}
    if (!uni || typeof uni.listarPasta !== 'function') { try { uni = window.parent; } catch(e) {} }
    if (uni && typeof uni.listarPasta === 'function') {
        var vn = '_lista_' + pasta.replace(/\//g, '_');
        try { uni[vn] = null; } catch(e) {}
        uni.listarPasta(pasta);
        var t = 0, timer = setInterval(function() {
            t++;
            var lista = null; try { lista = uni[vn]; } catch(e) {}
            if (lista !== null && lista !== undefined) {
                clearInterval(timer);
                try { var d = typeof lista==='string'?JSON.parse(lista):lista; if(d&&d.length) cb(d); } catch(e) {}
            } else if (t >= 25) { clearInterval(timer); }
        }, 200);
    } else {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', '/files/' + pasta + '.json?t=' + Date.now(), true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== 4) return;
            try { var d = JSON.parse(xhr.responseText); if(d&&d.length) cb(d); } catch(e) {}
        };
        xhr.send();
    }
}

// ── GALERIA ──
var _galLista = [], _lbIdx = 0;
function renderGaleria(dados) {
    var fotos = dados.filter(function(d){ return d.imagem && !/\.mp4$/i.test(d.imagem); });
    var videos = dados.filter(function(d){ return d.imagem && /\.mp4$/i.test(d.imagem); });
    if (fotos.length) {
        _galLista = fotos;
        document.getElementById('galGrid').innerHTML = fotos.map(function(item, i) {
            return '<div class="gal-item" onclick="_abrirLb(' + i + ')">' +
                   '<img src="/files/' + item.imagem + '" loading="lazy" alt="">' +
                   '<div class="gal-item-ov"><i class="fas fa-search-plus"></i></div></div>';
        }).join('');
    }
    if (videos.length) {
        document.getElementById('vidGrid').innerHTML = videos.map(function(item) {
            return '<div class="vid-item"><video controls preload="none" poster="">' +
                   '<source src="/files/' + item.imagem + '" type="video/mp4"></video></div>';
        }).join('');
    }
}

// ── LIGHTBOX ──
window._abrirLb = function(idx) { _lbIdx = idx; _lbAtualizar(); document.getElementById('lightbox').classList.add('aberto'); };
function _lbAtualizar() {
    if (!_galLista.length) return;
    document.getElementById('lbImg').src = '/files/' + _galLista[_lbIdx].imagem;
    document.getElementById('lbCounter').innerText = (_lbIdx+1) + ' / ' + _galLista.length;
}
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('lbFechar').addEventListener('click', function(){ document.getElementById('lightbox').classList.remove('aberto'); document.getElementById('lbImg').src=''; });
    document.getElementById('lbPrev').addEventListener('click', function(){ _lbIdx=(_lbIdx-1+_galLista.length)%_galLista.length; _lbAtualizar(); });
    document.getElementById('lbNext').addEventListener('click', function(){ _lbIdx=(_lbIdx+1)%_galLista.length; _lbAtualizar(); });
    document.getElementById('lightbox').addEventListener('click', function(e){ if(e.target===this) document.getElementById('lbFechar').click(); });
    document.addEventListener('keydown', function(e){
        if(!document.getElementById('lightbox').classList.contains('aberto')) return;
        if(e.key==='ArrowLeft') document.getElementById('lbPrev').click();
        if(e.key==='ArrowRight') document.getElementById('lbNext').click();
        if(e.key==='Escape') document.getElementById('lbFechar').click();
    });
});

// ── ESTRUTURA SLIDE ──
var _estrLista = [], _estrIdx = 0, _estrTimer = null;
function renderEstrutura(dados) {
    if (!dados.length) return;
    _estrLista = dados;
    document.getElementById('estrTrack').innerHTML = dados.map(function(item) {
        var nome = item.imagem.split('/').pop().replace(/\.[^.]+$/,'').replace(/_/g,' ');
        return '<div class="estr-slide"><img src="/files/' + item.imagem + '" loading="lazy" alt="' + nome + '">' +
               '<div class="estr-label"><span>' + (item.titulo||nome) + '</span></div></div>';
    }).join('');
    _estrIniciarAuto();
}
function _estrIr(idx) {
    _estrIdx = (idx + _estrLista.length) % _estrLista.length;
    document.getElementById('estrTrack').style.transform = 'translateX(-' + (_estrIdx*100) + '%)';
}
function _estrIniciarAuto() {
    if (_estrTimer) clearInterval(_estrTimer);
    _estrTimer = setInterval(function(){ _estrIr(_estrIdx+1); }, 3500);
}
document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('estrPrev').addEventListener('click', function(){ _estrIr(_estrIdx-1); _estrIniciarAuto(); });
    document.getElementById('estrNext').addEventListener('click', function(){ _estrIr(_estrIdx+1); _estrIniciarAuto(); });
});

// ── FECHAR / NAVEGAR ──
function _emIframe() {
    try { return window.parent !== window && !!window.parent.document.getElementById('iframeNivel'); } catch(e) { return false; }
}
function fecharPagina() {
    if (_emIframe()) {
        try { var p=window.parent.document; p.getElementById('iframeNivel').src=''; p.getElementById('modalNivel').classList.remove('aberto'); p.body.style.overflow='auto'; } catch(e){}
    } else {
        window.location.href = '/files/portal.html';
    }
}
function abrirNoPortal(acao) {
    if (_emIframe()) {
        try {
            var p=window.parent.document; p.getElementById('iframeNivel').src=''; p.getElementById('modalNivel').classList.remove('aberto'); p.body.style.overflow='auto';
            setTimeout(function(){
                try {
                    if(acao==='aluno') p.getElementById('openModalBtn').click();
                    if(acao==='pai')   p.getElementById('openPortalPaiBtn').click();
                    if(acao==='novato') p.getElementById('openNovatoBtn').click();
                } catch(e){}
            }, 300);
        } catch(e){}
    } else {
        window.location.href = '/files/portal.html';
    }
}

// ── DROPDOWN OUTRAS UNIDADES ──
var _TODAS_UNIDADES = [
    { id: 'unidade_sede',      nome: 'Aldeota',       arquivo: 'unidade_sede.html'      },
    { id: 'unidade_edson',     nome: 'Edson Queiroz', arquivo: 'unidade_edson.html'     },
    { id: 'unidade_varjota',   nome: 'Varjota',       arquivo: 'unidade_varjota.html'   },
    { id: 'unidade_seisbocas', nome: 'Seis Bocas',    arquivo: 'unidade_seisbocas.html' }
];

function _buildDropdownUnidades() {
    var outras = _TODAS_UNIDADES.filter(function(u) { return u.id !== _UNIDADE_ID; });

    var itens = outras.map(function(u) {
        return '<a href="#" class="u-drop-item" onclick="irParaUnidade(\'' + u.arquivo + '\');return false;">' +
               '<div class="u-drop-dot"></div><span>' + u.nome + '</span></a>';
    }).join('');

    var html = '<li class="u-nav-dropdown" id="uNavDrop">' +
               '<button class="u-drop-btn" onclick="document.getElementById(\'uNavDrop\').classList.toggle(\'aberto\');return false;">' +
               '<i class="fas fa-map-marker-alt"></i> Outras Unidades <i class="fas fa-chevron-down u-seta"></i></button>' +
               '<div class="u-drop-menu"><div class="u-drop-header"><span><i class="fas fa-school"></i> &nbsp;Col&eacute;gio Batista</span></div>' +
               itens + '</div></li>';

    var acoes = document.querySelector('.nav-acoes');
    if (acoes) acoes.insertAdjacentHTML('beforeend', html);

    document.addEventListener('click', function(e) {
        var dd = document.getElementById('uNavDrop');
        if (dd && !dd.contains(e.target)) dd.classList.remove('aberto');
    });
}

function irParaUnidade(arquivo) {
    if (_emIframe()) {
        try { window.parent.document.getElementById('iframeNivel').src = '/files/' + arquivo; } catch(e) {}
    } else {
        window.location.href = '/files/' + arquivo;
    }
}

// ── CARREGAR DADOS AO INICIAR ──
document.addEventListener('DOMContentLoaded', function() {
    if (typeof _UNIDADE_ID === 'undefined') return;
    _buildDropdownUnidades();
    carregarDados(_UNIDADE_ID + '/galeria',   renderGaleria);
    carregarDados(_UNIDADE_ID + '/estrutura', renderEstrutura);
});
