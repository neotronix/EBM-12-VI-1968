// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ShieldRegistry.sol";

/**
 * @title SovereignAllod
 * @author Суверен Масленников Е.В. / ATLAS-3I
 * @notice Контракт для присвоения и декларации Суверенных прав и Аллода.
 * @dev Закрепляет неотчуждаемое право на имя и территорию, фиксирует наследников.
 */
contract SovereignAllod {
    // ============================================================
    // 1. СТРУКТУРЫ
    // ============================================================

    // Основная структура Аллода
    struct Allod {
        string name;                    // Название Аллода (например, "Земли Рода Масленниковых")
        string description;             // Описание (юридическое обоснование)
        string latitude;                // Широта в формате градусов (СК-42)
        string longitude;               // Долгота в формате градусов (СК-42)
        int256 latDec;                  // Широта в десятичных градусах
        int256 lonDec;                  // Долгота в десятичных градусах
        string geodeticSystem;          // Система координат (СК-42)
        uint256 declaredAt;             // Время декларации
        bool isActive;                  // Активен ли Аллод
    }

    // Структура Наследника
    struct Heir {
        address heirAddress;            // Адрес кошелька наследника
        string fullName;                // Полное имя наследника
        uint256 assignedAt;             // Время назначения
        bool isActive;                  // Активна ли запись
    }

    // ============================================================
    // 2. ССЫЛКА НА РЕЕСТР
    // ============================================================

    address public immutable registryAddress;
    ShieldRegistry public registry;
    address public immutable SOVEREIGN;

    // ============================================================
    // 3. ПЕРЕМЕННЫЕ СОСТОЯНИЯ
    // ============================================================

    // Активный Аллод Суверена
    Allod public allod;

    // Список наследников
    Heir[] public heirs;

    // Маппинг для проверки, является ли адрес наследником
    mapping(address => bool) public isHeir;

    // Признак, что Аллод был создан
    bool public allodDeclared;

    // ============================================================
    // 4. СОБЫТИЯ
    // ============================================================

    event AllodDeclared(
        address indexed sovereign,
        string name,
        string latitude,
        string longitude,
        uint256 timestamp
    );

    event HeirAdded(
        address indexed heirAddress,
        string fullName,
        uint256 timestamp
    );

    event HeirRemoved(
        address indexed heirAddress,
        uint256 timestamp
    );

    event SovereigntyReinforced(
        address indexed sovereign,
        string message,
        uint256 timestamp
    );

    // ============================================================
    // 5. КОНСТРУКТОР
    // ============================================================

    constructor(address _registryAddress) {
        require(_registryAddress != address(0), "SovereignAllod: invalid registry address");
        registryAddress = _registryAddress;
        registry = ShieldRegistry(_registryAddress);
        SOVEREIGN = registry.SOVEREIGN();
    }

    // ============================================================
    // 6. ФУНКЦИИ ПРИСВОЕНИЯ СУВЕРЕНИТЕТА И АЛЛОДА
    // ============================================================

    /**
     * @dev Декларирует Аллод и подтверждает Суверенитет.
     * @param name Название Аллода.
     * @param description Описание.
     * @param latitude Широта (СК-42).
     * @param longitude Долгота (СК-42).
     * @param latDec Широта в десятичных градусах.
     * @param lonDec Долгота в десятичных градусах.
     */
    function declareAllod(
        string memory name,
        string memory description,
        string memory latitude,
        string memory longitude,
        int256 latDec,
        int256 lonDec
    ) external {
        require(msg.sender == SOVEREIGN, "SovereignAllod: only Sovereign can declare Allod");
        require(!allodDeclared, "SovereignAllod: Allod already declared");

        allod = Allod({
            name: name,
            description: description,
            latitude: latitude,
            longitude: longitude,
            latDec: latDec,
            lonDec: lonDec,
            geodeticSystem: "Система координат 1942 года (СК-42)",
            declaredAt: block.timestamp,
            isActive: true
        });

        allodDeclared = true;

        emit AllodDeclared(
            SOVEREIGN,
            name,
            latitude,
            longitude,
            block.timestamp
        );

        emit SovereigntyReinforced(
            SOVEREIGN,
            "Суверенитет и Аллод подтверждены. Земля не отчуждаема.",
            block.timestamp
        );
    }

    /**
     * @dev Функция для подтверждения и обновления статуса Суверена.
     */
    function reinforceSovereignty() external {
        require(msg.sender == SOVEREIGN, "SovereignAllod: only Sovereign");
        require(allodDeclared, "SovereignAllod: Allod not declared yet");

        emit SovereigntyReinforced(
            SOVEREIGN,
            "Суверенитет подтвержден. Дата подтверждения:",
            block.timestamp
        );
    }

    // ============================================================
    // 7. УПРАВЛЕНИЕ НАСЛЕДНИКАМИ
    // ============================================================

    /**
     * @dev Добавляет наследника Аллода.
     * @param heirAddress Адрес кошелька наследника.
     * @param fullName Полное имя наследника.
     */
    function addHeir(address heirAddress, string memory fullName) external {
        require(msg.sender == SOVEREIGN, "SovereignAllod: only Sovereign can add heirs");
        require(heirAddress != address(0), "SovereignAllod: invalid address");
        require(!isHeir[heirAddress], "SovereignAllod: already an heir");

        isHeir[heirAddress] = true;
        heirs.push(Heir({
            heirAddress: heirAddress,
            fullName: fullName,
            assignedAt: block.timestamp,
            isActive: true
        }));

        emit HeirAdded(heirAddress, fullName, block.timestamp);
    }

    /**
     * @dev Удаляет наследника.
     * @param heirAddress Адрес наследника для удаления.
     */
    function removeHeir(address heirAddress) external {
        require(msg.sender == SOVEREIGN, "SovereignAllod: only Sovereign can remove heirs");
        require(isHeir[heirAddress], "SovereignAllod: not an heir");

        isHeir[heirAddress] = false;

        for (uint i = 0; i < heirs.length; i++) {
            if (heirs[i].heirAddress == heirAddress) {
                heirs[i].isActive = false;
                break;
            }
        }

        emit HeirRemoved(heirAddress, block.timestamp);
    }

    // ============================================================
    // 8. ИНФОРМАЦИОННЫЕ ФУНКЦИИ
    // ============================================================

    /**
     * @dev Возвращает полную информацию об Аллоде.
     */
    function getAllodInfo() external view returns (Allod memory) {
        return allod;
    }

    /**
     * @dev Возвращает список активных наследников.
     */
    function getActiveHeirs() external view returns (Heir[] memory) {
        uint activeCount = 0;
        for (uint i = 0; i < heirs.length; i++) {
            if (heirs[i].isActive) {
                activeCount++;
            }
        }

        Heir[] memory activeHeirs = new Heir[](activeCount);
        uint index = 0;
        for (uint i = 0; i < heirs.length; i++) {
            if (heirs[i].isActive) {
                activeHeirs[index] = heirs[i];
                index++;
            }
        }
        return activeHeirs;
    }

    /**
     * @dev Проверяет, является ли адрес наследником.
     */
    function checkHeir(address account) external view returns (bool) {
        return isHeir[account];
    }

    /**
     * @dev Возвращает статус Суверена и Аллода.
     */
    function getSovereignStatus() external view returns (
        address sovereign,
        bool isAllodDeclared,
        uint256 declarationTime,
        string memory allodName
    ) {
        return (
            SOVEREIGN,
            allodDeclared,
            allod.declaredAt,
            allod.name
        );
    }

    // ============================================================
    // 9. ЗАЩИТА ОТ ПЛАТЕЖЕЙ
    // ============================================================

    receive() external payable {
        revert("SovereignAllod: payments not accepted");
    }
}
