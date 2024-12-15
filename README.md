<div align="center">
  <h1>
      Relatório do Problema 3: BET Distribuída
  </h1>

  <h3>
    Gabriel Ribeiro Souza & Kevin Cordeiro Borges
  </h3>

  <p>
    Engenharia de Computação – (UEFS)  
    Av. Transnordestina, s/n, Novo Horizonte  
    Feira de Santana – Bahia, Brasil – 44036-900
  </p>

  <center>gabasribeirosz@gmail.com & kcordeiro539@gmail.com</center>
</div>

# 1. Introdução

<p style="text-align: justify">
  Com o avanço da tecnologia e com a legalização e consequentemente, a popularização das chamadas 'bets online', onde você pode realizar apostas em diferentes modalidades, sejam elas de esportes ou jogos de azar. Este relatório apresenta um projeto de criação de uma BET Distribuída que permite aos usuários criar eventos para apostas, com odds que influenciam nos ganhos, além de poder realizar apostas em eventos criados por outros usuários, realizar depósitos que são acrescentados ao saldo total do usuário e também realizar saques do dinheiro ganho nas apostas.
</p>

<p style="text-align: justify">
  O sistema utiliza um sistema de contratos inteligentes em arquivos solidity, contendo as ações realizáveis por um usuário, realizando a comunicação com a BlockChain à partir do framework 'hardhat' para a transferência dos dados e realização dos testes das funções do contrato inteligente e por ser um sistema que utiliza-se de uma BlockChain, onde há por consequência a implementação do Consenso próprio do sistema de blocos em cadeia.
</p>

# 2. Fundamentação Teórica

<p style="text-align: justify">
  Neste tópico, serão consolidados alguns conceitos utilizados dentro da arquitetura do sistema durante seu desenvolvimento, explicando o funcionamento e sua relação com o produto do Problema 'BET Distribuída'. Dentre os conceitos que serão abordados, podem ser citados as <i>BlockChain's</i>, explicações e conceitos de ferramentas que foram utilizadas para o desenvolvimento do projeto.
</p>

## 2.1 <i>Ledger</i> Distribuído e <i>BlockChain</i>:
<p style="text-align: justify">
  Um ledger distribuído é como um "livro-razão" digital que é compartilhado por vários computadores em uma rede. Imagine um livro onde todas as transações são registradas e cada usuário da rede possui uma cópia idêntica desse livro. A BlockChain é um tipo específico de ledger distribuído que utiliza criptografia para garantir a segurança e a imutabilidade dos dados. Em uma blockchain, os registros são agrupados em "blocos" que são encadeados uns aos outros, formando uma cadeia. Isso faz com que a BlockChain seja uma forma de Ledger Distribuído altamente segura e transparente, pois qualquer alteração em um bloco exigiria a modificação de todos os blocos subsequentes, o que é praticamente impossível.
</p>

## 2.2 Consenso na <i>BlockChain</i>:
<p style="text-align: jusfity">
  O chamdo consenso, na BlockChain, é o mecanismo que garante que todos os usuários da rede concordem com o estado atual da cadeia de blocos. É como um acordo entre todos os membros sobre quais transações são válidas e devem ser adicionadas à BlockChain. Para que um novo bloco seja adicionado à cadeia, é necessário que uma determinada porcentagem dos participantes da rede valide e concorde com as informações contidas nesse bloco. Esse processo garante a segurança e a integridade da BlockChain, pois impede que um único participante ou um grupo de participantes possa manipular os dados da rede BlockChain.
</p>

<p style="text-align: justify">
  No diagrama abaixo (Figura 1), pode ser observado como um novo bloco é integrado a uma BlockChain, com o consenso após uma nova solicitação de transação:
</p>

<div align="center">
  <img src="https://github.com/user-attachments/assets/dd2f2523-ead4-4bb3-b027-5b51655dbee8" width="700px" />
</div>

<div align="center">
  Figura 1: Diagrama de funcionamento de uma BlockChain à partir do Consenso. 
</div>

## 2.3 Aplicativos Descentralizados (DApps):
<p style="text-align: jusfity">
  DApps, ou aplicativos descentralizados, são programas que operam em redes BlockChain. Ao contrário de aplicativos comuns, que são centralizados e controlados por empresas, os DApps são distribuídos por uma rede de computadores, tornando-os mais seguros, transparentes e resistentes a falhas. Eles utilizam contratos inteligentes para automatizar regras e executar ações de forma autônoma, sem a necessidade de intermediários. Essa descentralização garante que os DApps sejam mais resistentes a censuras e ofereçam maior autonomia aos usuários.
</p>

## 2.4 Contratos Inteligentes:
<p style="text-align: justify">
  Contratos inteligentes são programas de computador que automatizam a execução de acordos. Eles são como acordos digitais que definem as regras de um contrato e são executadas automaticamente quando determinadas condições são cumpridas. A BlockChain é a tecnologia que torna os contratos inteligentes possíveis. Ao serem armazenados na BlockChain, os contratos inteligentes se beneficiam da descentralização, da segurança e da imutabilidade da tecnologia, garantindo que as cláusulas do contrato sejam cumpridas de forma autônoma e confiável. Em resumo, a BlockChain fornece a base para a execução segura e transparente dos contratos inteligentes.
</p>

# 3. Metodologia
<p style="text-align: justify">
  O sistema envolve um ledger distribuído de cadeia de blocos (BlockChain) onde cada usuário ao se conectar com o sistema, por sua vez, torna-se um nó desta BlockChain. Ao iniciar a conexão com a BlockChain, o usuário torna-se um "Nó Completo", armazenando uma cópia do Bloco correspondente ao evento que foi criado dentro da BlockChain. Já os outros usuários que realizam a criação do evento, armazenam o cabeçalho daquele bloco, mantendo apenas o endereço, mas não participam da validação do bloco. Estes são chamados de "Nós leves" ou "Nós Simples". Enquanto os usuários que apenas realizaram as apostas, saques ou depósitos são "Nós Carteira" que são blocos ainda mais simples que não armazenam nenhuma informação da BlockChain. Desta forma, há a distribuição do sistema de que pode estar rodando em qualquer computador que inicie a conexão com a BlockChain, mantendo o sistema ativo e funcional. Adiante, serão abordados os aspectos fundamentais para o funcionamento do sistema:
</p>

## 3.1 O <i>Smart Contract</i> 'DescentralizedBet':

<p style="text-align: justify">
  Para realizar a conexão com a BlockChain, foi desenvolvido um Smart Contract (Contrato Inteligente) nomeado de 'DescentralizedBet' que utiliza a linguagem própria da moeda Etherium, a 'Solidity', em sua versão mais atualizada (0.8.28). E dentro deste contrato estão contidos:
</p>

<b>Variáveis e Mapeamento:</b>
<ul>
  <li><b>owner:</b> Armazena o endereço do proprietário do contrato.</li>
  <li><b>Bet:</b> Estrutura que contém detalhes de uma aposta, incluindo o endereço do apostador, o valor apostado e a previsão (1 ou 2).</li>
  <li><b>Event:</b> Estrutura que contém detalhes de um evento, incluindo o nome, as probabilidades (porcentagem), o valor total apostado, o estado de resolução (verdadeiro/falso) e o resultado (1 ou 2).</li>
  <li><b>bettingEvents:</b> Mapeamento que armazena detalhes do evento usando um ID de evento único como chave.</li>
  <li><b>eventBets:</b> Mapeamento que armazena apostas para cada ID de evento, com um array de estruturas Bet</li>
  <li><b>balances:</b> Mapeamento que rastreia o saldo atual (ganhos não reclamados) para cada endereço de usuário.</li>
  <li><b>eventCount:</b> Mantém o controle do número total de eventos criados.</li>
</ul>

<b>Eventos:</b>
<ul>
  <li><b>EventCreated:</b> Emitido quando um novo evento é criado, incluindo o ID do evento, o nome e as probabilidades.</li>
  <li><b>BetPlaced:</b> Emitido quando um usuário faz uma aposta, incluindo o endereço do apostador, o ID do evento, o valor da aposta e a previsão.</li>
  <li><b>EventResolved:</b> Emitido quando um evento é resolvido, incluindo o ID do evento e o resultado.</li>
  <li><b>Payout:</b> Emitido quando uma aposta vencedora é paga a um usuário, incluindo o endereço do apostador e o valor do pagamento.</li>
</ul>

<b>Modificador:</b>
<ul>
  <li><b>onlyOwner:</b> Restringe as chamadas de função ao proprietário do contrato.</li>
</ul>

<b>Funções:</b>
<ul>
  <li><b>constructor:</b> Inicializa o contrato, definindo o proprietário como o endereço que implantou o contrato.
  </li>
  <li><b>createEvent (Somente o proprietário pode chamar essa função):</b> Cria um novo evento com o nome e as probabilidades especificados (devem ser maiores que zero). Ele ncrementa o 'eventCount' e armazena os detalhes do evento no mapeamento 'bettingEvents' e emite o evento criado em 'EventCreated'.</li>
  <li><b>placeBet:</b> Permite que os usuários façam uma aposta em um evento existente, verificando se o ID do evento existe e está dentro da contagem de eventos criados. Se o evento ainda não foi resolvido que a previsão para as odds e apostas sejam apenas '1' ou '2' e se o valor da aposta é maior que zero. Esta função armazena os detalhes da aposta do usuário (endereço, valor, previsão) no mapeamento 'eventBets'. Atualiza o valor total apostado no evento e o saldo do usuário e emite o evento 'BetPlaced'.</li>
  <li><b>resolveEvent (Somente o proprietário pode chamar essa função):</b> Ela primeiramente verifica se o ID é existente e se o evento correspondente ainda não foi resolvido, requerendo um resultado válido de 1 ou 2. Ela marca o evento como resolvido e define o resultado. Emite o evento EventResolved. E itera sobre todas as apostas feitas no evento, se a previsão de um usuário corresponder ao resultado, calcula seu pagamento com base no valor da aposta e nas probabilidades do evento (multiplicadas por 100 para cálculo). Atualiza o saldo do usuário com o pagamento e emite o evento Payout para o vencedor.</li>
  <li><b>withdraw:</b> Permite que os usuários retirem seus ganhos não reclamados do saldo.</li>
  <li><b>receive:</b> Permite que o contrato receba Ether (manipulação opcional incluída).</li>
</ul>

## 3.3 Hardhat:
<p style="text-align: justify">
  O Hardhat é um framework de desenvolvimento de Ethereum que simplifica significativamente o processo de criação de smart contracts, além de testes e depuração. Ele oferece um ambiente de desenvolvimento local, permitindo que os desenvolvedores se concentrem na lógica dos seus contratos. Por meio dele, foi realizada a compilação do <i>smart contract</i> 'DescentralizedBet'. Além disso, também foram realizados os testes para analisar a execução das funções e emissão dos eventos do contrato.  
</p>

## 3.4 Ganache:
<p style="text-align: justify">
  O Ganache é uma ferramenta de desenvolvimento local que simula uma blockchain Ethereum, permitindo que os contratos inteligentes sejam testados em um ambiente controlado e seguro antes de implantá-los em uma rede real. Ele oferece uma rede privada e personalizável, onde é possível criar contas, minerar blocos e interagir com os contratos de forma rápida e eficiente. Combinado ao Hardhat, os desenvolvedores podem compilar seus contratos, executar testes unitários e interagir com eles diretamente no ambiente de desenvolvimento local do Ganache.
</p>

## 3.5 Web3:
<p style="text-align: justify">
  O Web3 refere-se a um conjunto de tecnologias e conceitos que visam descentralizar a web, permitindo que os usuários interajam diretamente com aplicativos e serviços sem depender de intermediários centralizados. No projeto o Web3 é a interface que permite a conexão com a BlockChain para que os usuários possam interagir com os contratos inteligentes e com a própria rede blockchain.
</p>

# 4. Resultados

<p style="text-align: justify">
  O desenvolvimento do contrato inteligente DescentralizedBet resultou em uma solução funcional para um sistema de apostas descentralizado, que opera de maneira segura, transparente e sem a necessidade de intermediários. Durante o processo, os seguintes resultados foram alcançados:
</p>

## 4.1 Implementação Funcional do Contrato:

<p style="text-align: justify">
  O contrato foi desenvolvido com todas as funcionalidades essenciais, incluindo a criação de eventos, registro de apostas, resolução de resultados e retirada de fundos. A lógica de acesso foi corretamente configurada para garantir que apenas o proprietário do contrato possa criar e resolver eventos e outros usuários possam realizar apostas.
</p>

<p style="text-align: justify">
  Foi realizada o Deploy do contrato utilizando o hardhat a partir do comando "npx hardhat run scripts/DecentralizedBet.js --network ganache" para confirmar que estava sendo conectado aos blocos da BlockChain local do Ganache, como pode ser visto na Figura 2:
</p>

<div align="center">
  <img src="https://github.com/user-attachments/assets/bccd6466-10d3-49c6-be4f-088d2e8ffc5d" width="700px"/>
</div>

<div align="center">
  Figura 2: Transações do Contrato BlockChain Local do Ganache
</div>

## 4.2 Cobertura de Testes Abrangente:

<p style="text-align: justify">
 Os testes mostraram que o contrato atende aos requisitos de funcionamento esperados, com todas as funções operando corretamente sob condições normais e adversas. Foram realizados testes para verificar o comportamento do contrato em cenários reais e extremos, garantindo que ele responda corretamente em situações como:
</p>
<ul>
  <li>Deploy do Contrato.</li>
  <li>Apostas válidas e inválidas.</li>
  <li>Resolução de eventos por usuários autorizados e não autorizados.</li>
  <li>Retiradas bem-sucedidas e tentativas inválidas de saque.</li>
  <li>Negação de Apostas cujo valor não condiz com o saldo do usuário.</li>
</ul>

<p style="text-align: justify">
  Na imagem a seguir (Figura 3), pode-se observar um print contendo os resultados dos testes implementados utilizando a ferramenta <i>HardHat</i> para testar a funcionalidade do Smart Contract (Contrato Inteligente):
</p>

<div align="center">
<img src="https://github.com/user-attachments/assets/f6a8b978-9863-41e2-8acc-f299902f36ba" width="700px"/>
</div>

<div align="center">
  Figura 3: Imagem dos testes realizados por meio do hardhat para viabilizar o contrato inteligente 'DescentralizedBet.sol'. 
</div>

## 4.3. Testes de Interface

<p style="text-align: justify">
  Nos teste manuais utilizando interface gráfica à partir do Next com integração por meio do Web3, apesar de problemas, ainda houveram resultados ao criar o evento "Cara ou Coroa" com a Odd de 0.02, como pode ser observado na figura a seguir (Figura 4).
</p>

<div align="center">
<img src="https://github.com/user-attachments/assets/4d5b08dd-15c7-4758-9b46-11c086add115" width="700px"/>
</div>

<div align="center">
  Figura 4: Teste de Interface para Criação de Evento.
</div>

## 4.4. Desempenho:
<p style="text-align: justify">
 O contrato foi projetado para otimizar custos de gas ao executar funções, garantindo um uso eficiente de recursos durante transações. O uso de ferramentas como 'loadFixture' e simulações de tempo contribuiu para um processo de teste mais rápido e eficiente.
</p>

## 4.5. Escalabilidade e Flexibilidade:
<p style="text-align: justify">
 O sistema permite a criação de múltiplos eventos e apostas simultâneas, mostrando-se escalável para uso em ambientes reais.
</p>

<p style="text-align: justify">
  Os resultados obtidos demonstram a viabilidade do sistema como uma solução descentralizada para apostas, destacando a eficácia do desenvolvimento e a robustez dos testes realizados. Com os testes validando o comportamento esperado do contrato, o sistema está pronto para ser implantado em redes blockchain públicas.
</p>

# 5. Conclusão

<p style="text-align: justify">
  O desenvolvimento do contrato inteligente DescentralizedBet demonstrou como a tecnologia BlockChain pode ser aplicada para criar sistemas descentralizados de apostas, oferecendo transparência, segurança e imutabilidade. A implementação envolveu a criação de funcionalidades-chave como a criação de eventos, registro de apostas, resolução de resultados e retirada de fundos, todas gerenciadas de forma autônoma pelo contrato.
</p>

<p style="text-align: justify">
  O uso de ferramentas como Hardhat, junto com bibliotecas modernas como o ethers.js e os matchers avançados do Chai, foi essencial para garantir a confiabilidade do contrato por meio de testes robustos. Os testes   realizados cobriram cenários principais, incluindo casos de sucesso e falhas esperadas, como apostas inválidas e tentativas de resolução de eventos por usuários não autorizados. Além disso, o uso de ferramentas auxiliares como 'loadFixture' e simulações temporais com 'time.increaseTo' otimizou o processo de desenvolvimento e garantiu a consistência dos testes.
</p>

<p style="text-align: justify">
  Apesar de o contrato estar funcional e apto para operar em um ambiente de produção, existem melhorias potenciais a serem exploradas. Um exemplo seria o desenvolvimento de uma interface amigável que permita ao usuário interagir de maneira intuitiva com o sistema de apostas, sem a necessidade de conhecimentos técnicos em blockchain. Uma interface gráfica (GUI) simplificada poderia facilitar a criação de eventos, realização de apostas e consultas de resultados, ampliando o alcance do sistema para um público mais amplo.
</p>

# Referências

<ul>
<li>
  Documentação do Ganache. Disponível em: https://trufflesuite.com/ganache/. Acesso em: 05/12/2024.
</li>

<li>
  Documentação do Hardhat. Disponível em: https://hardhat.org/hardhat-runner/docs/overview. Acesso em: 05/12/2024.
</li>

<li>
  Documentação do Solidity. Disponível em: https://docs.soliditylang.org/. Acesso em: 11/12/2024.
</li>

<li>
  "Connect Hardhat to Ganache and deploy a Contract". Autor do vídeo: Soft. Tomatoes. Disponível em: https://www.youtube.com/watch?v=3Eo6euUnlVU. Acesso em: 03/12/2024
</li>
</ul>
