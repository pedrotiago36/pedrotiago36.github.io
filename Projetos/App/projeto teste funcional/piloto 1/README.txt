================================================================================
                     SGE - SISTEMA DE GESTÃO ESCOLAR
                      Tela de Login + Menu Principal - FMX
================================================================================

DESCRIÇÃO:
-----------
Sistema de Gestão Escolar profissional desenvolvido em Delphi FMX com visual 
moderno glassmorphism e animações fluidas. Inclui tela de login e menu principal.

CREDENCIAIS DE TESTE:
---------------------
  Usuário: admin
  Senha: 123

================================================================================
                        IMAGENS NECESSÁRIAS (FLATICON)
================================================================================

Acesse: https://www.flaticon.com/

Baixe as imagens BRANCAS (white) em formato PNG e salve na pasta "img" 
ao lado do executável com os seguintes nomes:

  TELA DE LOGIN:
  --------------
  1. capelo.png       → Buscar: "graduation cap" (Logo central)
  2. student.png      → Buscar: "student" (Botão Aluno)
  3. teacher.png      → Buscar: "teacher" (Botão Professor)
  4. admin.png        → Buscar: "clipboard" (Botão Administrativo)
  5. university.png   → Buscar: "university" (Botão Universidade)
  6. user.png         → Buscar: "user" (Campo usuário)
  7. lock.png         → Buscar: "padlock" (Campo senha)

  MENU PRINCIPAL (NOVAS!):
  ------------------------
  8. home.png         → Buscar: "home" (Menu Início)
  9. calendar.png     → Buscar: "calendar" (Menu Calendário)
  10. grades.png      → Buscar: "report" ou "grades" (Menu Notas)
  11. finance.png     → Buscar: "money" ou "finance" (Menu Financeiro)
  12. settings.png    → Buscar: "settings" ou "gear" (Menu Configurações)
  13. logout.png      → Buscar: "logout" ou "exit" (Botão Sair)
  14. notification.png → Buscar: "notification" ou "bell" (Card Notificações)

  OBJETOS ESCOLARES (ANIMAÇÃO DE QUEDA):
  --------------------------------------
  15. book.png        → Buscar: "book" (Livro)
  16. pencil.png      → Buscar: "pencil" (Lápis)
  17. eraser.png      → Buscar: "eraser" (Borracha)
  18. notebook.png    → Buscar: "notebook" (Caderno)
  19. ruler.png       → Buscar: "ruler" (Régua)

ESTRUTURA DE PASTAS:
--------------------
  Win32/
  └── Debug/
      ├── SGE.exe
      └── img/
          ├── capelo.png        ← Logo
          ├── student.png       ← Aluno
          ├── teacher.png       ← Professor
          ├── admin.png         ← Administrativo
          ├── university.png    ← Universidade
          ├── user.png          ← Campo usuário
          ├── lock.png          ← Campo senha
          ├── home.png          ← Menu Início
          ├── calendar.png      ← Menu Calendário
          ├── grades.png        ← Menu Notas
          ├── finance.png       ← Menu Financeiro
          ├── settings.png      ← Menu Configurações
          ├── logout.png        ← Botão Sair
          ├── notification.png  ← Card Notificações
          ├── book.png          ← Animação
          ├── pencil.png        ← Animação
          ├── eraser.png        ← Animação
          ├── notebook.png      ← Animação
          └── ruler.png         ← Animação

================================================================================

CORES DO PROJETO:
-----------------
  - Vermelho Principal: #D33327
  - Vermelho Escuro/Vinho: #7D2728
  - Dourado: #FDCD62
  - Dourado Claro: #FFEABB
  - Menu Background: #501818 (90% opacidade)

RECURSOS VISUAIS:
-----------------
  TELA DE LOGIN:
  ✓ Fundo gradiente vermelho/vinho diagonal
  ✓ Card glassmorphism com logo e capelo
  ✓ Animação de pulso no logo
  ✓ 4 botões de área com ícones
  ✓ Objetos escolares caindo (15 objetos animados)
  ✓ Animação de shake em erro
  
  MENU PRINCIPAL:
  ✓ Header com logo e saudação personalizada
  ✓ Menu lateral deslizante (glassmorphism)
  ✓ Logo com pulso animado no menu
  ✓ 5 itens de menu com hover effects
  ✓ 4 cards de dashboard com hover
  ✓ Objetos escolares caindo no fundo
  ✓ Overlay escurecido ao abrir menu
  ✓ Animações de entrada e saída

FLUXO DO APP:
-------------
  1. Login → Selecionar área → Inserir credenciais → ENTRAR
  2. Menu Principal → Dashboard com cards
  3. Botão ☰ → Abre menu lateral
  4. Clique fora ou ✕ → Fecha menu
  5. Sair → Volta para Login

COMPATIBILIDADE:
----------------
  - Delphi Athens 12.3
  - Delphi Alexandria 11.x
  - Plataforma: Win32

================================================================================
                         Desenvolvido com Claude AI
================================================================================
