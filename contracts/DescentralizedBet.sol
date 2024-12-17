// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title DescentralizedBet
 * @dev Contrato para gerenciar apostas descentralizadas em eventos.
 * Inclui criação de eventos, apostas, resolução de eventos e retirada de fundos.
 */
contract DescentralizedBet {
    // Endereço do proprietário do contrato
    address public owner;

    // Estrutura para representar uma aposta
    struct Bet {
        address bettor; // Endereço do apostador
        uint256 amount; // Valor apostado em wei
        uint8 prediction; // Previsão: 1 ou 2
    }

    // Estrutura para representar um evento de aposta
    struct Event {
        string name; // Nome do evento
        uint256 odds; // Odds em porcentagem (ex.: 200 = odds de 2.00)
        uint256 totalAmount; // Total de valores apostados
        bool resolved; // Indica se o evento foi resolvido
        uint8 result; // Resultado do evento: 1 ou 2
    }

    // Mapeamento de eventos por ID
    mapping(uint256 => Event) public bettingEvents;

    // Mapeamento de apostas associadas a cada evento
    mapping(uint256 => Bet[]) public eventBets;

    // Mapeamento de saldos para cada endereço
    mapping(address => uint256) public balances;

    // Contador global de eventos
    uint256 public eventCount;

    // Eventos para emitir logs importantes
    event EventCreated(uint256 indexed eventId, string name, uint256 odds);
    event BetPlaced(address indexed bettor, uint256 indexed eventId, uint256 amount, uint8 prediction);
    event EventResolved(uint256 indexed eventId, uint8 result);
    event Payout(address indexed bettor, uint256 payout);
    event WithdrawalAttempt(address indexed user, uint256 amount);
    event ContractBalance(uint256 balance);

    // Modificador para funções restritas ao proprietário
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    /**
     * @dev Construtor do contrato. Define o chamador inicial como o proprietário.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Cria um novo evento de aposta.
     * @param _name Nome do evento.
     * @param _odds Odds do evento (em porcentagem).
     */
    function createEvent(string memory _name, uint256 _odds) public onlyOwner {
        require(_odds > 0, "Odds must be greater than zero.");

        // Incrementa o contador de eventos
        eventCount++;

        // Adiciona o novo evento ao mapeamento
        bettingEvents[eventCount] = Event({
            name: _name,
            odds: _odds,
            totalAmount: 0,
            resolved: false,
            result: 0
        });

        emit EventCreated(eventCount, _name, _odds);
    }

    /**
     * @dev Realiza uma aposta em um evento específico.
     * @param eventId ID do evento.
     * @param prediction Previsão do apostador (1 ou 2).
     */
    function placeBet(uint256 eventId, uint8 prediction) public payable {
        require(eventId > 0 && eventId <= eventCount, "Event does not exist.");
        require(!bettingEvents[eventId].resolved, "Event already resolved.");
        require(prediction == 1 || prediction == 2, "Invalid prediction.");
        require(msg.value > 0, "Bet amount must be greater than zero.");

        // Registra a aposta no evento
        eventBets[eventId].push(Bet({
            bettor: msg.sender,
            amount: msg.value,
            prediction: prediction
        }));

        // Atualiza o total apostado no evento
        bettingEvents[eventId].totalAmount += msg.value;

        // Atualiza o saldo do apostador
        balances[msg.sender] += msg.value;

        emit BetPlaced(msg.sender, eventId, msg.value, prediction);
    }

    /**
     * @dev Resolve um evento, definindo seu resultado.
     * @param eventId ID do evento.
     * @param result Resultado do evento (1 ou 2).
     */
    function resolveEvent(uint256 eventId, uint8 result) public onlyOwner {
        require(eventId > 0 && eventId <= eventCount, "Event does not exist.");
        require(!bettingEvents[eventId].resolved, "Event already resolved.");
        require(result == 1 || result == 2, "Invalid result.");

        // Marca o evento como resolvido e define o resultado
        bettingEvents[eventId].resolved = true;
        bettingEvents[eventId].result = result;

        emit EventResolved(eventId, result);

        // Calcula os pagamentos para apostas vencedoras
        uint256 totalPayout;
        for (uint256 i = 0; i < eventBets[eventId].length; i++) {
            Bet storage bet = eventBets[eventId][i];
            if (bet.prediction == result) {
                uint256 payout = (bet.amount * bettingEvents[eventId].odds) / 100;
                balances[bet.bettor] += payout;
                totalPayout += payout;
                emit Payout(bet.bettor, payout);
            }
        }
    }

    /**
     * @dev Permite que os usuários retirem seus saldos acumulados.
     */
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance to withdraw.");
        require(address(this).balance >= amount, "Contract does not have enough funds.");

        // Reseta o saldo do usuário antes de transferir
        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed.");

        emit WithdrawalAttempt(msg.sender, amount);
        emit ContractBalance(address(this).balance);
    }

    /**
     * @dev Retorna todas as apostas de um evento.
     * @param eventId ID do evento.
     */
    function getEventBets(uint256 eventId) public view returns (Bet[] memory) {
        return eventBets[eventId];
    }

    /**
     * @dev Permite que o contrato receba fundos diretamente.
     */
    receive() external payable {}

    /**
     * @dev Permite que o proprietário deposite fundos no contrato.
     */
    function deposit() external payable {
        require(msg.value > 0, "Must send Ether to deposit.");
    }
}
