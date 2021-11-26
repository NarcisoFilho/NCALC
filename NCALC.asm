; ╔══════════════════════════════════════════════════════════════════╗
; ║                   UFRGS - Instituto de Informática               ║
; ║    Trabalho de Arquitetura e Organização de Computadores I       ║
; ║                         INF01108                                 ║
; ╠══════════════════════════════════════════════════════════════════╣
; ║    Estudante: Manoel Narciso Reis Soares Filho                   ║
; ║    Data: 21/11/2021                                              ║
; ╠══════════════════════════════════════════════════════════════════╣
; ║    Programa para o processador Intel 80x86                       ║
; ║                                                                  ║
; ║   → Abre arquivo de texto com valores reais e calcula a soma,    ║
; ║   a média aritmética dos valores e o dígito verificador de cada  ║
; ║   entrada                                                        ║
; ║                                                                  ║
; ║   → Obs. 1: Separador decimal pode ser vírgula ou ponto          ║
; ║   → Obs. 2: Na entrada do nome do arquivo, a extensão (.txt) é   ║
; ║   opcional                                                       ║
; ║   → Obs.3: Cada entrada real deve estar numa linha separada do   ║
; ║   arquivo                                                        ║
; ║   → Obs.4: É permitida a presença de espaços e tabulações antes  ║
; ║   e/ou depois das entradas                                       ║
; ║   → Obs.5: Intervalo válido para as entradas = [0,00 ; 499,99]   ║
; ║   → Obs.6: Utilize duas casas decimais                           ║
; ║   → Obs.7: Linhas com entradas inválidas serão desconsideradas   ║
; ╠══════════════════════════════════════════════════════════════════╣
; ║   Lista de interrupções de software utilizadas                   ║
; ║                                                                  ║
; ║   → INT 21h (DOS API)- código contido em ah define interrupção   ║
; ║     ♦ ah = 02h: Imprime caractere na tela.                       ║
; ║     Tecnicamente envia caractere para a saída padrão, que pode   ║
; ║     ser redirecionada a partir do DOS 2.0                        ║
; ║         IN:                                                      ║
; ║             dl = Caractere a ser enviado                         ║
; ║         OUT:                                                     ║
; ║             al = Último caractere escrito                        ║
; ║             CF = Limpo se operação for bem-sucedida. Caso con-   ║
; ║            trário estará ativa                                   ║
; ║     ♦ ah = 0Ah: Obtém entrada do usuário pela entrada padrão e a ║
; ║     a salva em buffer definido pelo usuário                      ║
; ║         IN:                                                      ║
; ║             DS:DX = Endereço do buffer para salvamento da entrada║
; ║     ♦ ah = 3Ch: Cria arquivo no disco                            ║
; ║         IN:                                                      ║
; ║             cx = Atributos do arquivo                            ║
; ║             ds:dx = "Nome do Arquivo"                            ║
; ║         OUT:                                                     ║
; ║             ax = Descritor do arquivo criado, ou cód. de erro    ║
; ║             CF = Limpo se operação for bem-sucedida. Caso con-   ║
; ║            trário estará ativa                                   ║
; ║     ♦ ah = 3Dh: Abre arquivo (existente) do disco, para leitura  ║
; ║         IN:                                                      ║
; ║             dx = "Nome do Arquivo"                               ║
; ║         OUT:                                                     ║
; ║             ax = Descritor do arquivo aberto, ou msg de erro     ║
; ║             CF = Limpo se operação for bem-sucedida. Caso con-   ║
; ║            trário estará ativa                                   ║
; ║     ♦ ah = 3Eh: Fecha arquivo aberto                             ║
; ║         IN:                                                      ║
; ║             bx = Descritor do arquivo a ser fechado              ║
; ║         OUT:                                                     ║
; ║             ax = Em caso de erro, indica qual foi a falha        ║
; ║             CF = Limpo se operação for bem-sucedida. Caso con-   ║
; ║            trário estará ativa                                   ║
; ║     ♦ ah = 3Fh: Lê determinada quantidade de bytes do arquivo    ║
; ║         IN:                                                      ║
; ║             bx = Descritor do arquivo                            ║
; ║             cx = Quantidade de bytes a ser lido                  ║
; ║             dx = Endereço de salvamento dos dados lidos          ║
; ║         OUT:                                                     ║
; ║             ax = Quantidade de bytes efetivamente lidos          ║
; ║             CF = Limpo se operação for bem-sucedida. Caso con-   ║
; ║            trário estará ativa                                   ║
; ║     ♦ ah = 40h: Escreve em um arquivo                            ║
; ║         IN:                                                      ║
; ║             bx = Descritor do arquivo                            ║
; ║             cx = Quantidade de bytes a ser escrito               ║
; ║             dx = Endereço inicial do dados a serem escritos      ║
; ║         OUT:                                                     ║
; ║             ax = Quantidade de bytes efetivamente lidos          ║
; ║             CF = Limpo se operação for bem-sucedida. Caso con-   ║
; ║            trário estará ativa                                   ║
; ╚══════════════════════════════════════════════════════════════════╝

    .model      small
    .stack
; Definições
TRUE    equ     1
FALSE   equ     0

; System
    ; Códigos de Retorno
    EXIT_SUCCESS     equ     0
    EXIT_FAILURE     equ     1
    EXIT_TEST        equ     77
    
    ; Códigos de Erros
    ERR_COD_DEFAULT         equ     0
    ERR_COD_OPEN_FILE       equ     1
    ERR_COD_CLOSE_FILE      equ     2
    ERR_COD_READ_FILE       equ     3
    ERR_COD_WRITE_FILE      equ     4

; Caracteres		
CR		equ		0Dh     ; Carriage Return        ( '\r' )
LF		equ		0Ah     ; Line Feed         
SPC     equ     20h     ; Espaço em branco
TAB     equ     09h     ; Tabulação              ( '\t' ) 
EOF     equ     0       ; End of File
EOS     equ     0       ; End of String          ( '\0' )
NULL    equ     0       ; 

; Interrupções
__DOS_API_      equ     21h
_putchar        equ     02h
_gets           equ     0Ah
_fcreate        equ     3Ch
_fopen          equ     3Dh
_fclose         equ     3Eh
_fread          equ     3Fh
_fwrite         equ     40h

; Códigos

; Arquivos - Modos
ARQ_READ        equ     00h
    
    .data
; Variáveis para o sistema de arquivos
FileName		db		256 dup (?)		; Nome do arquivo a ser lido
; OutputFileName  db		256 dup (?)		; Nome do arquivo de saida
OutputFileName  db		"abc.res", EOS
FileBuffer		db		10  dup (?)		; Buffer de leitura do arquivo
FileHandle		dw		0				; Handler do arquivo
FileNameBuffer	db		150 dup (?)

; Variáveis para a aplicação
    ; Entrada
    entrada         db      2000 dup (?)    ; String que salva leitura do arquivo
    
    qtd_linhas      dw      0               ; Quantidade de linhas da entrada
    qtd_linhas_val  dw      0               ; Quantidade de linhas da entrada
    status_linha    db      100  dup (0)    ; Status de validade de cada linha
    
    entrada_int     dw      100 dup (0)     ; Partes inteiras
    entrada_frac    dw      100 dup (0)     ; Partes fracionárias

    soma            dw      0               ; Soma das entradas
    soma_frac       dw      0               ; Parte fracionária da Soma
    media           dw      0               ; Média das entradas
    media_frac      dw      0               ; Parte fracionária da Média das entradas
    dig_verif       db      100 dup (?)     ; Dígito verificador de cada linha
    
    ; Contadores
    linha_atual          db      0               ; Contador para linha atual
    indice_str_atual     dw      0               ; Posição na string 
    cont_aux             db      0               ; Contador multiuso auxiliar
    
    ; Constantes
    const_2         db      2         ; Constante 2
    const_10        db      10        ; Constante 10
    const_100       db      100       ; Constante 100
    
    ; Gerais
    string_buffer   db      100 dup (?)     ; Buffer de uso geral
    
; Mensagens de erro
MsgErroDefault      db	CR, LF,"Erro !!                                            ", CR, LF, 0
MsgErroOpenFile		db	CR, LF,"Erro na abertura do arquivo !!                     ", CR, LF, 0
MsgErroCloseFile    db	CR, LF,"Falha ao fechar arquivo. Risco de perda de dados !!", CR, LF, 0
MsgErroReadFile		db	CR, LF,"Erro na leitura do arquivo  !!                     ", CR, LF, 0
MsgErroWriteFile    db	CR, LF,"Erro na escrita do arquivo  !!                     ", CR, LF, 0

QTD_MSGS_ERROS      equ  5
TAM_MSGS_ERROS      equ  56


; Outras Mensagens
MsgEntrada    		    db	CR, LF, LF, "___________________ Contabilidade 1.0 ___________________", CR, LF, LF, 0
MsgPedeArquivo		    db	"Nome do arquivo: ", 0
MsgFN		            db	CR, LF, "Feliz Natal! ", CR, LF, 0
 
; Mensagens de teste 
MsgTesteColetarEntrada  db	CR, LF, LF, "Entrada lida do arquivo: ", CR, LF, LF, 0
MsgTesteTratarEntrada   db	CR, LF, LF, "Entrada tratada: ", CR, LF, LF, 0
MsgTesteFormatarEntrada db	CR, LF, LF, "Entrada formatada: ", CR, LF, LF, 0
MsgTesteAQL             db	CR, LF, LF, "Analise qualitativa: ", CR, LF, LF, 0
MsgTesteAQT             db	CR, LF, LF, "Analise quantitativa: ", CR, LF, LF, 0
MsgTesteQtdLinhas       db	CR, LF, LF, "Qtd de linhas: ", 0
MsgTesteSoma            db	CR, LF, LF, "Soma: ", 0
MsgTesteMedia           db	CR, LF, LF, "Media: ", 0
  	
    .code
    .startup
	
	; Inicialização
    
    ; Apresentação
    lea		bx, MsgEntrada
	call	puts
            
    ; Entrada - Nome do Arquivo
	call	GetFileName

    ; Coleta de dados do arquivo
    call    AbreArquivo
    call    ColetaDados
    call    FechaArquivo
    
    ;Teste Coleta de Dados
    lea     bx, MsgTesteColetarEntrada
    call    puts
    lea     bx, entrada
    call    puts
    
    ; Tratamento
    call   TrataDados
    ; Teste do Tratamento dos Dados
    lea     bx, MsgTesteTratarEntrada
    call    puts
    lea     bx, entrada
    call    puts
    
    call   AnaliseQualitativa      ; Testa validade das linhas, no que se refere à presença de caracteres proibidos
        ;Teste Análise qualitativa
        lea     bx, MsgTesteAQL
        call    puts
        mov     cx, 15
        lea     bx, status_linha
        loop_teste_AQL:
            mov     dl, byte ptr [bx]
            add     dl, '0'
            call    putchar

            mov     dl, LF
            call    putchar

            inc     bx
        loop    loop_teste_AQL

    call   FormataEntrada
        ; Teste da formatação dos Dados
        lea     bx, MsgTesteFormatarEntrada
        call    puts
        lea     bx, entrada
        call    puts
 
    ; Processamento
    call   ComputaEntrada            ; Computa partes inteiras e fracionárias da entrada
    call   AnaliseQuantitativa       ; Testa validade das linhas, no que se refere ao intervalo válido da entrada
        ;Teste Análise Quantitativa
        lea     bx, MsgTesteAQT
        call    puts
        mov     cx, 15
        lea     bx, status_linha
        loop_teste_AQT:
            mov     dl, byte ptr [bx]
            add     dl, '0'
            call    putchar

            mov     dl, LF
            call    putchar

            inc     bx
        loop    loop_teste_AQT
        
    call   CalculaSoma                      ; Calcula soma
    call   CalculaMedia                    ; Calcula media
    ;call   CalculaDVs                      ; Calcula dígitos verificadores
        
                ;Teste da computação dos valores
                lea     bx, string_buffer
                mov     cx, qtd_linhas
                mov     dl, LF
                
                lea     di, entrada_int
                lea     si, entrada_frac
                
                call    putchar

                while_teste:
                    mov     ax, word ptr [di]
                    call    sprintf_w
                    call    puts    
                    
                    mov     dl, '-'
                    call    putchar
                    
                    mov     ax, word ptr [si]
                    call    sprintf_w
                    call    puts   
                    
                    mov     dl, LF
                    call    putchar
                    
                    add     si, 2
                    add     di, 2        
                loop    while_teste        
    
                ; Teste qtd de linhas
                lea     bx, MsgTesteQtdLinhas
                call    puts
                
                lea     bx, string_buffer
                mov     ax, qtd_linhas
                call    sprintf_w
                call    puts    
      
                ; Teste soma
                lea     bx, MsgTesteSoma
                call    puts
                
                ; Parte inteira
                lea     bx, string_buffer
                mov     ax, soma
                call    sprintf_w
                call    puts    
                
                mov     dl, '-'
                call    putchar
                
                ; Parte fracionária
                mov     ax, soma_frac
                call    sprintf_w
                call    puts    
      
                ; Teste média
                lea     bx, MsgTesteMedia
                call    puts
                
                ; Parte inteira
                lea     bx, string_buffer
                mov     ax, media
                call    sprintf_w
                call    puts    
                
                mov     dl, '-'
                call    putchar
                
                ; Parte fracionária
                mov     ax, media_frac
                call    sprintf_w
                call    puts    
      
    ; Saída
    call   SalvaOutputEmArquivo
    ;call   ImprimeOutputTela
    
    .exit
;--------------------------------------------------------------------


;═══════════════════════════════════════════════════════════════════════
;-----------------------------------------------------------------------
; Sub-rotinas de E/S

; ╔══════════════════════════════════════════════════════════════════╗
; ║ putchar: Imprime caractere na tela                               ║
; ║     IN:                                                          ║
; ║         dl -> Caractere a ser impresso                           ║
; ║     OUT:                                                         ║
; ║         al -> Último caractere impresso                          ║
; ╚══════════════════════════════════════════════════════════════════╝
putchar	    proc	near
    ; Salva registradores
    call    SalvaRegs
    
    push    bx
    
    ; Escrever caractere
    mov		ah, _putchar        ;| 
    int		__DOS_API_          ;|> putchar( dl )
    
    pop    bx
		
    ;Fim
    call    RestauraRegs        ; Restaura valor dos registradores
    ret
putchar 	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ puts: Imprime string na tela                                     ║
; ║     IN:                                                          ║
; ║         DS:BX-> Endereço da string a ser impressa                ║
; ║     OUT:                                                         ║
; ║          void                                                    ║
; ╚══════════════════════════════════════════════════════════════════╝
puts	proc	near
    ; Salva registradores
    call    SalvaRegs
    
    ; while( *string != '\0' ){
    while_puts:
        mov		dl, [bx]
        cmp		dl, EOS    
        je		fim_puts        ; Testa se alcançou o indicador de fim de string

        call    putchar         ; putchar( *string )
        
        inc		bx		        ; string++
	jmp		while_puts ; }
		
    fim_puts:
        call    RestauraRegs        ; Restaura valor dos registradores
        ret
puts	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ perror: Imprime mensagem de erro                                 ║
; ║     IN:                                                          ║
; ║         dx -> Código da mensagem de erro                         ║
; ║     OUT:                                                         ║
; ║          void                                                    ║
; ╚══════════════════════════════════════════════════════════════════╝
perror	proc	near
    ; Salvar registradores
    call    SalvaRegs
    
    cmp     dx, QTD_MSGS_ERROS
    jb      perro_multiplic         ; if( !(COD_ERROR <= QTD_MSGS_ERROS ) )
    mov     dx, ERR_COD_DEFAULT     ; COD_ERROR = ERR_COD_DEFAULT
    
    perro_multiplic:
        ; ax = COD_MSG * 35
        mov     ax, TAM_MSGS_ERROS
        mul     dx
        mov     bx, ax                     ; bx = 35 * COD_MSG
    
    lea     bx, MsgErroDefault[ bx ]   ; bx = &MsgErroDefault[ 35 * COD_MSG ]   
    call    puts    
    
    ; Fim
    call    RestauraRegs    ; Restaurar registradores
    ret
perror	endp

;═══════════════════════════════════════════════════════════════════════
;-----------------------------------------------------------------------
; Sub-rotinas de manipulação de arquivos


; ╔══════════════════════════════════════════════════════════════════╗
; ║ fcreate: Cria arquivo                                            ║
; ║     IN:                                                          ║
; ║         cx   -> Atributos do arquivo                             ║
; ║         ds:dx-> "Nome do arquivo"                                ║
; ║     OUT:                                                         ║
; ║         ax   -> Descritor do arquivo                             ║
; ╚══════════════════════════════════════════════════════════════════╝
fcreate	proc	near
	mov		ah, _fcreate
	int		__DOS_API_
    ret
fcreate	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ fopen: Abre arquivo                                              ║
; ║     IN:                                                          ║
; ║         al   -> Modo de abertura                                 ║
; ║         ds:dx-> "Nome do arquivo"                                ║
; ║     OUT:                                                         ║
; ║         ax   -> Descritor do arquivo                             ║
; ╚══════════════════════════════════════════════════════════════════╝
fopen	proc	near
	mov		ah, _fopen
	int		__DOS_API_
    ret
fopen	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ fclose: Fecha arquivo                                            ║
; ║     IN:                                                          ║
; ║         bx   -> Descritor do arquivo                             ║
; ║     OUT:                                                         ║
; ║          void                                                    ║
; ╚══════════════════════════════════════════════════════════════════╝
fclose	proc	near
	mov		ah, _fclose
	int		__DOS_API_
    ret
fclose	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ fgetc: Lê um caractere de arquivo de texto                       ║
; ║     IN:                                                          ║
; ║         bx   -> Descritor do arquivo                             ║
; ║         dx   -> End de destino                                   ║
; ║     OUT:                                                         ║
; ║          void                                                    ║
; ╚══════════════════════════════════════════════════════════════════╝
fgetc	proc	near
    ; Salva valor dos registradores
    call    SalvaRegs
    
    ; Leitura do byte
	mov		ah, _fread     ; Índice da interrupção, no vetor de interrupções 21h
    mov     cx, 1          ; Ler somente 1 byte
	int		__DOS_API_
    
    ; Verificação de êxito na operação
    jnc     verificar_eof
    mov     dx, ERR_COD_READ_FILE
    call    perror
    .exit   EXIT_FAILURE
    
    ; Verificação de fim do arquivo
    verificar_eof:
        cmp     ax, NULL
        jne     fim_exito_fgetc
        mov     di, dx
        mov     [di], EOF
    
    ; Fim em caso de êxito
    fim_exito_fgetc:
        call    RestauraRegs ; Restaura valor dos registradores
        ret
fgetc	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ fputc: Escreve um caractere num arquivo de texto                 ║
; ║     IN:                                                          ║
; ║         bx    -> Descritor do arquivo                            ║
; ║         ds:dx -> End do dado a ser escrito                       ║
; ║     OUT:                                                         ║
; ║          void                                                    ║
; ╚══════════════════════════════════════════════════════════════════╝
fputc	proc	near
    ; Salva valor dos registradores
    call    SalvaRegs
    
    ; Escrita do byte
	mov		ah, _fwrite    ; Índice da interrupção, no vetor de interrupções 21h
    mov     cx, 1          ; Escrever somente 1 byte
	int		__DOS_API_
    
    ; Verificação de êxito na operação
    jnc     fim_exito_fputc
    mov     dx, ERR_COD_WRITE_FILE
    call    perror
    .exit   EXIT_FAILURE
        
    ; Fim em caso de êxito
    fim_exito_fputc:
        call    RestauraRegs ; Restaura valor dos registradores
        ret
fputc	endp


;═══════════════════════════════════════════════════════════════════════
;-----------------------------------------------------------------------
; Sub-rotinas gerais


; ╔══════════════════════════════════════════════════════════════════╗
; ║ SalvaRegs: Empilha os dados dos registradores                    ║
; ║     IN: void                                                     ║
; ║     OUT: void                                                    ║
; ║                                                                  ║
; ║     Obs.: Deve-se usar a sub-rotina dual, RestauraRegs, antes do ║
; ║     fim do escopo onde SalvaRegs foi chamada                     ║
; ╚══════════════════════════════════════════════════════════════════╝
SalvaRegs	proc	near
    ; Remove o end de retorno do topo da pilha
    pop     end_retorno_SalvaRegs
    
    ; Empilha valor dos registradores
    push    ax
    push    bx
    push    cx
    push    dx
    
    push    di
    push    si
    
    ; Coloca o end de retorno novamente no topo da pilha
    push    end_retorno_SalvaRegs   
	
    ; Fim
    ret
    
    ; Local Variables
    end_retorno_SalvaRegs   dw  0
    
SalvaRegs	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ RestauraRegs: Desempilha os dados dos registradores, salvos an-  ║
; ║ teriormente por meio da sub-rotina SalvaRegs                     ║
; ║     IN: void                                                     ║
; ║     OUT: void                                                    ║
; ║                                                                  ║
; ║     Obs.: Sub-rotina dual de RestauraRegs                        ║
; ╚══════════════════════════════════════════════════════════════════╝
RestauraRegs	proc	near
    ; Remove o end de retorno do topo da pilha
    pop     end_retorno_RestauraRegs
    
    ; Desempilha valor dos registradores
    pop    si
    pop    di
    
    pop    dx
    pop    cx
    pop    bx
    pop    ax
    
    ; Coloca o end de retorno novamente no topo da pilha
    push    end_retorno_RestauraRegs  
	
    ; Fim
    ret
    
    ; Local Variables
    end_retorno_RestauraRegs   dw  0
    
RestauraRegs	endp


;═══════════════════════════════════════════════════════════════════════
;-----------------------------------------------------------------------
; Sub-rotinas de manipulação de strings

; ╔══════════════════════════════════════════════════════════════════╗
; ║ strrem: Remove elemento de uma string e desloca os elementos pos-║
; ║ teriores (até encontra um EOS, incluindo-o) uma posição para a   ║
; ║ esquerda                                                         ║
; ║     IN:                                                          ║
; ║         ds:di: End do elemento a ser removido                    ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ║                                                                  ║
; ╚══════════════════════════════════════════════════════════════════╝
strrem	proc	near
    ; Inicialização
    call    SalvaRegs
    
    loop_strrem:
        cmp     [di], EOS
        je      fim_strrem
        
        mov     dx, [di+1]
        mov     [di], dx
        inc     di
        
        jmp     loop_strrem
    
    fim_strrem:
        call    RestauraRegs    ; Restaura valores dos registradores
        ret 
strrem	endp



; ╔══════════════════════════════════════════════════════════════════╗
; ║ stradd: Adiciona elemento em uma string e desloca os elementos   ║
; ║ posteriores (até encontra um EOS, incluindo-o) uma posição para a║
; ║ direita                                                          ║
; ║     IN:                                                          ║
; ║         dl: Elemento a ser adicionado                            ║
; ║         ds:di: End cujo elemento será adicionado removido        ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
stradd	proc	near
    ; Inicialização
    call    SalvaRegs
    
    loop_stradd:        
        mov     dh, dl
        mov     dl, byte ptr [di]
        mov     byte ptr [di], dh
        inc     di
        
        cmp     dh, EOS
        jne     loop_stradd
    
    ; Fim
        call    RestauraRegs    ; Restaura valores dos registradores
        ret 
stradd	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ sprintf_w: Salva número de 16 bits em string como texto          ║
; ║     IN:                                                          ║
; ║         AX-> Valor a ser salvo                                   ║
; ║         DS:BX-> Endereço da string de destino                    ║
; ║     OUT:                                                         ║
; ║          void                                                    ║
; ╚══════════════════════════════════════════════════════════════════╝
;
;--------------------------------------------------------------------
;Função: Converte um inteiro (n) para (string)
;		 sprintf(string, "%d", n)
;
;void sprintf_w(char *string->BX, WORD n->AX) {
;	k=5;
;	m=10000;
;	f=0;
;	do {
;		quociente = n / m : resto = n % m;	// Usar instrução DIV
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
;		n = resto;
;		m = m/10;
;		--k;
;	} while(k);
;
;	if (!f)
;		*string++ = '0';
;	*string = '\0';
;}
;
;Associação de variaveis com registradores e memória
;	string	-> bx
;	k		-> cx
;	m		-> sw_m dw
;	f		-> sw_f db
;	n		-> sw_n	dw
;--------------------------------------------------------------------

sprintf_w	proc	near
    ; Salvar registradores
    call    SalvaRegs
    
;void sprintf_w(char *string, WORD n) {
	mov		sw_n,ax

;	k=5;
	mov		cx,5
	
;	m=10000;
	mov		sw_m,10000
	
;	f=0;
	mov		sw_f,0
	
;	do {
sw_do:

;		quociente = n / m : resto = n % m;	// Usar instrução DIV
	mov		dx,0
	mov		ax,sw_n
	div		sw_m
	
;		if (quociente || f) {
;			*string++ = quociente+'0'
;			f = 1;
;		}
	cmp		al,0
	jne		sw_store
	cmp		sw_f,0
	je		sw_continue
sw_store:
	add		al,'0'
	mov		[bx],al
	inc		bx
	
	mov		sw_f,1
sw_continue:
	
;		n = resto;
	mov		sw_n,dx
	
;		m = m/10;
	mov		dx,0
	mov		ax,sw_m
	mov		bp,10
	div		bp
	mov		sw_m,ax
	
;		--k;
	dec		cx
	
;	} while(k);
	cmp		cx,0
	jnz		sw_do

;	if (!f)
;		*string++ = '0';
	cmp		sw_f,0
	jnz		sw_continua2
	mov		[bx],'0'
	inc		bx
sw_continua2:


;	*string = '\0';
	mov		byte ptr[bx],0
		
;}
    
    ; Fim
    call    RestauraRegs    ; Restaurar registradores
	ret
	
    ; Local Variables
    sw_m        dw      0
    sw_n        dw      0
    sw_f        dw      0
sprintf_w	endp


;═══════════════════════════════════════════════════════════════════════
;-----------------------------------------------------------------------
; Sub-rotinas específicas para a aplicação

; ╔══════════════════════════════════════════════════════════════════╗
; ║ AbreArquivo: Abre arquivo e confere abertura                     ║
; ║     IN:                                                          ║
; ║         dx-> "Nome do arquivo"                                   ║
; ║     OUT:                                                         ║
; ║         ax-> Descritor do arquivo ( FALSE em caso de erro )      ║
; ╚══════════════════════════════════════════════════════════════════╝
AbreArquivo	proc	near
	mov		al, ARQ_READ
	lea		dx,FileName
	
    call    fopen
    jc      falha_abertura_arq      ; if( !fopen() ) perror(), exit(1);
        
    ; Caso a abertura do arquivo seja bem sucedida
    mov     FileHandle, ax
    ret
        
    falha_abertura_arq:
        ; Caso a abertura do arquivo falhe
        mov     dx, ERR_COD_OPEN_FILE
        call    perror
        .exit   EXIT_FAILURE
     
AbreArquivo	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ FechaArquivo: Fecha arquivo e verifica o êxito na operação       ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
FechaArquivo	proc	near
	mov		bx, FileHandle
	
    call    fclose
    		
    fim_FechaArquivo:
        ret
    
    falha_fechamento_arq:
        ; Caso o fechamento do arquivo falhe
        mov     dx, ERR_COD_CLOSE_FILE
        call    perror
        .exit   EXIT_FAILURE
        
FechaArquivo	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ GetFileName: Lê o nome do arquivo do teclado                     ║
; ║     IN: void                                                     ║
; ║     OUT: void                                                    ║
; ╚══════════════════════════════════════════════════════════════════╝
GetFileName	proc	near

	;	puts("Nome do arquivo: ");
	lea		bx,MsgPedeArquivo
	call	puts

	;	// Lê uma linha do teclado
	;	FileNameBuffer[0]=100;
	;	gets(ah=0x0A, dx=&FileNameBuffer)
	mov		ah, _gets
	lea		dx, FileNameBuffer
	mov		byte ptr FileNameBuffer, 100
	int		__DOS_API_

	;	// Copia do buffer de teclado para o FileName
	;	for (char *s=FileNameBuffer+2, char *d=FileName, cx=FileNameBuffer[1]; cx!=0; s++,d++,cx--)
	;		*d = *s;		
	lea		si,FileNameBuffer+2
	lea		di,FileName
	mov		cl,FileNameBuffer+1
	mov		ch,0
	mov		ax,ds						; Ajusta ES=DS para poder usar o MOVSB
	mov		es,ax
	rep 	movsb

	;	// Coloca o '\0' no final do string
	;	*d = '\0';
	mov		byte ptr es:[di],0
	ret
GetFileName	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ ColetaDados: Coleta os dados do arquivo e salva na var entrada   ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
ColetaDados    proc	near 
    ; Inicizalização
    call    SalvaRegs           ; Salva valores dos registradores
    
    mov     bx, FileHandle      ; Descritor do arquivo
    lea     dx, FileBuffer      ; Endereço do buffer para leitura do arquivo
    lea     di, entrada         ; Endereço do destino das leituras

    loop_ColetaDados:
        call    fgetc               ; *FileBuffer = fgetc( arq )

        mov     cl, FileBuffer      ; *(entrada + indice) = FileBuffer
        mov     [di], cl            ; *(entrada + indice) = FileBuffer

        cmp     FileBuffer, EOF
        je      fim_ColetaDados     ; Checa se alcançou o fim do arquivo

        inc     di                  ; entrada++
        jmp	    loop_ColetaDados

    fim_ColetaDados:
        mov     [di], EOS       ; Substitui o EOF do final da entrada por EOS
        call    RestauraRegs    ; Restaura valores dos registradores
        ret
    
ColetaDados	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ TrataDados: Remove eventuais espaços, tabulações e hífens da en- ║
; ║ trada e substitui eventuais pontos por vírgulas                  ║
; ║ vírgulas                                                         ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
TrataDados    proc	near 
    ; Inicialização
    call    SalvaRegs
    
    mov     di, 0       ; di = 0
    mov     si, 0       ; si = 0
    
    ; Loop de tratamento dos dados    
    loop_TrataDados:
        ; Testa se alcançou fim da string
        cmp     entrada[si], EOS
        je      fim_TrataDados
        
        ; Substituição dos pontos
        cmp     entrada[si], '.'
        jne     removals
        
        mov     entrada[si], ','
        
        ; ; Remoções dos espaços, tabulações e hífens
        removals:
            mov     bx, 3
            loop_removals:
                mov     cl, byte ptr chars_array_for_removal[bx-1]
                cmp     entrada[si], cl
                jne     decrementa_bx            
                
                lea     di, entrada[si]         ;|
                call    strrem    ;|>Remove elemento
                                                
                dec     si                      ;|
                jmp     incrementa_si           ;|> Recomeça loop _TrataDados
                
                decrementa_bx:
                    dec     bx
                    je      incrementa_si
                    jmp     loop_removals
        
        ; Incrementa si
        incrementa_si:
            inc     si
            jmp     loop_TrataDados
    
    fim_TrataDados:
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  
    ; Local variables
    chars_array_for_removal:    db  ' ', TAB, '-'
              
TrataDados	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ AnaliseQualitativa: Confere se as entradas das linhas possuem ca-║
; ║ racteres inválidos. Nos casos positivos, marca as linhas que con-║
; ║ tém as entradas não permitidas como inválidas                    ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
AnaliseQualitativa    proc	near 
    ; Inicialização
    call    SalvaRegs
    lea     si, entrada
    mov     bx, 0               ; Contador da linha
    mov     status_linha[0], TRUE  ; Inicializa status_linha[0]
    
    
    ; Loop de conferência
    loop_AnaliseQualitativa:

        cmp     byte ptr [si], EOS
        je      fim_AnaliseQualitativa  ; Testa fim de string

        
        cmp     byte ptr [si], CR      ;|           
        je      inc_bx_AQL             ;|           
        cmp     byte ptr [si], LF      ;|           
        je      inc_bx_AQL             ;|> Testa se nova linha           
        
        cmp     byte ptr [si], ','      ;|    
        je      inc_si_AQL              ;|
        cmp     byte ptr [si], '0'      ;|
        jb      invalida_AQL            ;|
        cmp     byte ptr [si], '9'      ;|> Nesse ponto do código só podem haver na entrada vírgulas e números
        ja      invalida_AQL            ;|
                
        inc_si_AQL:
            inc     si
            jmp     loop_AnaliseQualitativa
        inc_bx_AQL:
            inc     bx
            ignora_NL_Repetido:
                inc     si
                cmp     byte ptr [si], EOS
                je      fim_AnaliseQualitativa  ; Testa fim de string
                cmp      byte ptr [si], CR      ;|           
                je       ignora_NL_Repetido     ;|           
                cmp      byte ptr [si], LF      ;|           
                je       ignora_NL_Repetido     ;|> Testa há nova linha repetido           
            
            mov     status_linha[bx], 1
            jmp     loop_AnaliseQualitativa
        invalida_AQL:
            mov     status_linha[bx], 0
            jmp     inc_si_AQL
            
        
    fim_AnaliseQualitativa:
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  

AnaliseQualitativa	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ FormataEntrada: Converte a parte fracionária em duas casas deci- ║
; ║ mais                                                             ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
FormataEntrada    proc	near 
    ; Inicialização
    call    SalvaRegs
    
    mov     di, 0       ; di = 0
    mov     si, 0       ; si = 0
    
    ; Loop de Formatação da Entrada    
    loop_FormataEntrada:
        ; Testa se alcançou fim da string
        cmp     entrada[si], EOS
        je      fim_TrataDados
        
        ; Correção de dígito único na parte fracionária
        cmp     entrada[si], ','
        jne     incrementa_si_FE
        
        cmp     entrada[si+2], CR
        je      add_zero_frac
        cmp     entrada[si+2], LF
        je      add_zero_frac
        cmp     entrada[si+2], EOS
        je      add_zero_frac
        
        jmp     incrementa_si_FE
        
        ; Adiciona zero na parte fracionária
        add_zero_frac:
            mov     dl, '0'
            lea     di, entrada[si+2]
            call    stradd       ; Insere 0 sa string
        
        ; Incrementa si
        incrementa_si_FE:
            inc     si
            jmp     loop_FormataEntrada
    
    fim_FormataEntrada:
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  
              
FormataEntrada	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ ComputaEntrada: Identifica partes inteiras e fracionárias da en- ║
; ║ trada. Também invalida linhas por caractere inválido             ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ║     Obs.: Ela testa a validade da linha somente levando em conta ║
; ║     a presença de caracteres não permitidos. Não avalia se o nú- ║
; ║     mero está dentro do intervalo permitido. Outra rotina faz    ║
; ║     isso                                                         ║
; ╚══════════════════════════════════════════════════════════════════╝
ComputaEntrada    proc	near 
    ; Inicialização
    call    SalvaRegs
    
    lea     si, entrada         ; String entrada em si
    mov     bx, 0               ; Contador para linha atual
    
    ; Loop de análise da entrada
    loop_ComputaEntrada:
        ; Verifica CR e/ou LF
        cmp      byte ptr [si], EOF                ;|
        je       fim_ComputaEntrada                ;|> if( *entrada == LF ) goto fim;
        cmp      byte ptr [si], CR                 ;|
        je       ignora_NL                         ;|> if( *entrada == '\r' ) goto loop_ComputaEntrada;
        cmp      byte ptr [si], LF                 ;|
        je       ignora_NL                         ;|> if( *entrada == LF ) goto loop_ComputaEntrada;
        jmp      loop_parte_inteira
        
        ignora_NL:
            inc     si
            jmp     loop_ComputaEntrada
                
        ; Parte Inteira
        loop_parte_inteira:
            ; Verifica fim da string
            cmp     byte ptr [si], EOS               ;|
            je      fim_ComputaEntrada      ;|> if( *entrada == '\0' ) goto fim_ComputaEntrada;
            ; Verifica Carriage Return
            cmp     byte ptr [si], CR               ;|
            je      NL_ComputaEntrada      ;|> if( *entrada == '\r' ) goto NL;
            ; Verifica Line Feed
            cmp     byte ptr [si], LF               ;|
            je      NL_ComputaEntrada      ;|> if( *entrada == '\r' ) goto NL;
            ; Verifica Vírgula
            cmp     byte ptr [si], ','               ;|
            je      loop_parte_frac         ;|> if( *entrada == '\r' ) goto frac;
            
            ; Verifica dígito inválido
            ; cmp     [si],'0'
            ; jb
            ; cmp     [si],'9'
            ; ja            
            
            ; Multiplica por dez ( ShiftLeft )
            mov     ax, entrada_int[bx]     ;|            
            mul     const_10                ;|
            mov     entrada_int[bx], ax     ;|> entrada_int *= 10
            
            ; Adiciona dígito
            mov     ah, 0                   ;|
            mov     al, byte ptr [si]                ;|
            sub     al, '0'                 ;|
            add     entrada_int[bx], ax     ;|> entrada_int[ linha_atual ] += *string - '0' 
            
            ; Incrementa si
            inc     si
            jmp     loop_parte_inteira
        
        ; Parte Fracionária
        loop_parte_frac:
            inc     si
            ; Verifica fim da string
            cmp     byte ptr [si], EOS               ;|
            je      fim_ComputaEntrada      ;|> if( *entrada == '\0' ) goto fim_ComputaEntrada;
            ; Verifica Carriage Return
            cmp     byte ptr [si], CR               ;|
            je      NL_ComputaEntrada      ;|> if( *entrada == '\r' ) goto NL;
            ; Verifica Line Feed
            cmp     byte ptr [si], LF               ;|
            je      NL_ComputaEntrada      ;|> if( *entrada == '\r' ) goto NL;
            ; Verifica Vírgula
            cmp     byte ptr [si], ','               ;|
            je      fim_ComputaEntrada      ;|> if( *entrada == '\r' ) goto frac;
            
            ; Verifica dígito inválido
            ; cmp     [si],'0'
            ; jb
            ; cmp     [si],'9'
            ; ja            
            
            ; Multiplica por dez ( ShiftLeft )
            mov     ax, entrada_frac[bx]     ;|            
            mul     const_10                 ;|
            mov     entrada_frac[bx], ax     ;|> entrada_frac *= 10
            
            ; Adiciona dígito
            mov     ah, 0                   ;|
            mov     al, byte ptr [si]       ;|
            sub     al, '0'                 ;|
            add     entrada_frac[bx], ax    ;|> entrada_frac[ linha_atual ] += *string - '0' 
            
            ; Incrementa si
            ;inc     si
            jmp     loop_parte_frac
            
        ; Nova linha
        NL_ComputaEntrada:
            add     bx, 2
            jmp     loop_ComputaEntrada
                        
    fim_ComputaEntrada:
        mov     ax, bx
        div     const_2          
        mov     qtd_linhas, ax
        
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  

ComputaEntrada	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ AnaliseQuantitativa: Confere se as entradas das linhas estão den-║
; ║ tro do intervalo permitido. Nos casos negativos, marca as linhas ║
; ║ que contém as entradas não permitidas como inválidas             ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
AnaliseQuantitativa    proc	near 
    ; Inicialização
    call    SalvaRegs
    mov     bx, 0               ; Contador da linha para 16 bits    
    mov     cx, qtd_linhas      ; Contador de repetições    
    mov     di, 0               ; Contador da linha para 8 bits
    mov     qtd_linhas_val, 0   ; Contador da qtd de linhas válidas
    
    ; Loop de conferência
    loop_AnaliseQuantitativa:   
        ; Testa parte inteira
        cmp     entrada_int[bx], 0                 ;|    
        jb      invalida_AQT                       ;|
        cmp     entrada_int[bx], 499               ;|    
        ja      invalida_AQT                       ;|> Testa se e in [0,499]
        
        ; Testa parte fracionária
        cmp     entrada_frac[bx], 0                ;|    
        jb      invalida_AQT                       ;|
        cmp     entrada_frac[bx], 99               ;|    
        ja      invalida_AQT                       ;|> Testa se e in [0,499]
        
        ; Incrementa bx
        inc_bx_AQT:
            cmp     byte ptr status_linha[di], TRUE
            jne     continua_inc_bx_AQT
            inc     qtd_linhas_val
            
            continua_inc_bx_AQT:
                add     bx, 2
                inc     di
    loop    loop_AnaliseQuantitativa    
        
    ; Fim
    fim_AnaliseQuantitativa:
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  

    ; Caso necessário, invalída linha    
    invalida_AQT:
        mov     byte ptr status_linha[di], FALSE
        jmp     inc_bx_AQT
        
AnaliseQuantitativa	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ CalculaSoma: Calcula soma das entradas válidas                   ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
CalculaSoma    proc	near 
    ; Inicialização
    call    SalvaRegs
    
    mov     soma, 0               ; Zera Acumulador
    mov     soma_frac, 0          ; Zera Acumulador das partes fracionárias
    mov     cx, qtd_linhas        ; Número de somas
    
    mov     si, 0     ; Contador para linha (16 bits)
    mov     di, 0     ; Contador para linha (8 bits)
    
    ; Soma
    loop_soma:
        ; Verificação de válidade da linha
        cmp     status_linha[di], TRUE
        jne     inc_conts_soma          ; Se linha não for válida não soma
        
        ; Parte inteira
        mov     ax, entrada_int[si]             ;| 
        add     soma, ax                        ;|> soma += *entrada_int
        
        ; Parte fracionárias
        mov     ax, entrada_frac[si]             ;| 
        add     soma_frac, ax                    ;|> soma_frac += *entrada_frac
        
        ; Incrementa contadores
        inc_conts_soma:
            add     si, 2           ; si+=2
            inc     di              ; di++
    loop    loop_soma
        
    ; Correção da parte fracionárias
    mov     ax, soma_frac
    div     const_100           ; al = soma_frac / 100 , ah = soma_frac % 100
    
    mov     bh, 0               ;
    mov     bl, al              ; soma += soma_frac/100 (parte inteira de soma_frac)
    add     soma, bx            ; soma += soma_frac/100 (parte inteira de soma_frac)

    
    mov     bl, ah              ; soma += soma_frac/100 (parte inteira de soma_frac)
    mov     soma_frac, bx       ; soma_frac = soma_frac%100 (parte fracionária da soma)
    
    cmp     soma_frac, 9
    ja      fim_CalculaSoma
    
    mov     ax, soma_frac
    mov     ah, 0
    mov     bl, 10
    mul     bl
    mov     soma_frac, ax
    
    ; Fim
    fim_CalculaSoma:
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  

CalculaSoma	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ CalculaMedia: Calcula média das entradas válidas                 ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
CalculaMedia    proc	near 
    ; Inicialização
    call    SalvaRegs
    
    ; Média parte Frácionaria
    mov     ax, soma_frac       ;|
    mov     bx, qtd_linhas_val  ;|
    div     bl                  ;|
                                ;|    
    mov     ah, 0               ;|
    div     const_100           ;|
    mov     al, ah              ;|
    mov     ah, 0               ;|
    mov     media_frac, ax      ;|> media_frac = ( soma_frac / qtd_linhas_val ) % 100
    
    ; Média parte Inteira
    mov     ax, soma            ;|
    mov     bx, qtd_linhas_val  ;|
    div     bl                  ;|
    mov     dh, ah              ;|
    mov     ah, 0               ;|
    mov     media, ax           ;|> media = soma / qtd_linhas_val
    
    mov     al, dh
    mov     ah, 0
    div     const_100
    mov     al, ah              ;|
    
    mov     al, dh
    mov     ah, 0
    add     media_frac, ax       ;|> media_frac += ( soma % qtd_linhas_val ) % 100
    
    fim_CalculaMedia:
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  

CalculaMedia	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ CalculaDVs: Calcula os dígitos verificadores de cada linha válida║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
CalculaDVs    proc	near 
    ; Inicialização
    call    SalvaRegs
        
    fim_CalculaDVs:
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  

CalculaDVs	endp


; ╔══════════════════════════════════════════════════════════════════╗
; ║ SalvaOutputEmArquivo: Salva resultado em arquivo de saída        ║
; ║     IN:                                                          ║
; ║         void                                                     ║
; ║     OUT:                                                         ║
; ║         void                                                     ║
; ╚══════════════════════════════════════════════════════════════════╝
SalvaOutputEmArquivo    proc	near 
    ; Inicialização
    call    SalvaRegs
    
    ; Criar arquivo .res
    ;lea     dx, FileName
    lea     dx, OutputFileName    ; Nome do arquivo de saída
    mov     cx, 0                 ; Atributos
    call    fcreate
    
    ; Grava dados
    mov     bx, ax
    lea     dx, FileBuffer  ; dx = &FileBuffer
    
    mov     si, 0           ; Índice do elemento sendo lida
    mov     cl, 0           ; Índice da linha sendo lida de cálculo
    mov     linha_des, 0    ; Índice da linha sendo lida de desenho
         
    jmp     testa_validade_SOEA 
    
    loop_grava_dados:
        cmp     entrada[si], EOS
        je      fim_SalvaOutputEmArquivo
                       
        mov     al, entrada[si]
        mov     FileBuffer, al
        call    fputc
        
        inc     si
        
        cmp     FileBuffer, LF
        je      incrementa_linha_cl
        cmp     FileBuffer, CR
        je      incrementa_linha_cl
        
        jmp     loop_grava_dados
        
        
        ; Incrementa linha quando encontra LF
        incrementa_linha_cl:                               
            cmp     entrada[si], EOS
            je      fim_SalvaOutputEmArquivo
                        
            pcd_2:
                mov     al, entrada[si]
                mov     FileBuffer, al
                call    fputc
                inc     si                          ; string++
            pcd_1:
                cmp     entrada[si], CR
                je      pcd_2
                cmp     entrada[si], LF
                je      pcd_2         ; Elimina os CR e LF colados
            
            inc     cl
            
            ; Testa Validade da linha
            testa_validade_SOEA:
                push    bx
                mov     bl, cl
                mov     bh, 0
                cmp     status_linha[bx], FALSE
                je      l_inv_SOEA
                       
            pop     bx
            inc     linha_des

            ; Grava contador no arquivo de saída
            mov     al, linha_des       ;| 
            mov     FileBuffer, al      ;|> Valor da linha atual ( de desenho )
            jmp     l_val_SOEA
            
            l_inv_SOEA:
                pop     bx
                mov     FileBuffer, ' '      ; Linha Inválida
                call    fputc                ; putchar( ' ' )
                mov     FileBuffer, '#'      ; 
                call    fputc                ; putchar( '#' )
                call    fputc                ; putchar( '#' )
                call    fputc                ; putchar( '#' )
                jmp     prossiga_SOEA
                
            l_val_SOEA:
            mov     ch, 3               ; Número de divisões                        
            loop_montar_contador_linha:
                ; Divide valor da linha por dez e usa resto
                mov     ah, 0
                mov     al, FileBuffer
                div     const_10            ; Divide ax por 10  
                
                push    ax                  ; Empilha Filebuffer % 10
                
                mov     FileBuffer, al      ; FileBuffer = FileBuffer / 10
                                
                dec     ch
                cmp     ch, 0
                ja     loop_montar_contador_linha
            
            mov     ch, 3               ; Número de gravações
            loop_gravar_contador_linha:
                pop     ax
                mov     FileBuffer, ah
                add     FileBuffer, '0'     ;|
                call    fputc               ;|> putchar( FileBuffer % 10 )
                
                dec     ch
                cmp     ch, 0
                ja      loop_gravar_contador_linha    
            
            prossiga_SOEA:            
                ; Grava TAB no arquivo de saída
                mov     FileBuffer, TAB
                call    fputc
                
                ; Grava hífen no arquivo de saída
                mov     FileBuffer, '-'
                call    fputc
                
                ; Grava TAB no arquivo de saída
                mov     FileBuffer, TAB
                call    fputc
                
                jmp     loop_grava_dados
    
    fim_SalvaOutputEmArquivo:
        ; Arquiva soma
        
        
        ; Fechar arquivo
        call    fclose
        call    RestauraRegs    ; Restaura valores dos registradores
        ret  
    ; Local Variables
    linha_des       db      0   ; Índice da linha sendo lida de desenho

SalvaOutputEmArquivo	endp


;═══════════════════════════════════════════════════════════════════════
;--------------------------------------------------------------------
    end
;--------------------------------------------------------------------
;═══════════════════════════════════════════════════════════════════════
