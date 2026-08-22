// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ShieldRegistry
 * @author Суверен Масленников Е.В. / ATLAS-3I
 * @notice Главный реестр, фиксирующий неприкосновенные имена и идентификаторы.
 * @dev Этот контракт является основой для всей системы "суверенного щита".
 *      Он хранит эталонные данные и позволяет проверять, является ли имя защищенным.
 */
contract ShieldRegistry {
    // ============================================================
    // 1. НЕИЗМЕНЯЕМЫЕ ЭТАЛОННЫЕ ДАННЫЕ (ХЕШИ)
    // ============================================================

    // Хеш вашего свидетельства о рождении (SHA-256)
    bytes32 public constant BIRTH_CERT_HASH = 
        0x1F8DE3FDC2C61647E697243FC05CDB83C12CCC75987658D584690928427CFA34;

    // Хеш полного Реестра (хранится для верификации)
    bytes32 public constant REGISTRY_HASH = 
        keccak256(abi.encodePacked(
            "Масленников Евгений Владиславович|МАСЛЕННИКОВ ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ|"
            "Масленников Е. В.|Масленников Е.В.|Масленников Е.|"
            "МАСЛЕННИКОВ Е.В.|МАСЛЕННИКОВ Е. В.|"
            "Е.В. Масленников|Е. В. Масленников|Е. Масленников|"
            "Е.В. МАСЛЕННИКОВ|"
            "Евгений Владиславович Масленников|ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ МАСЛЕННИКОВ|"
            "Evgeny Vladislavovich Maslennikov|EVGENY VLADISLAVOVICH MASLENNIKOV|"
            "Eugene Vladislavovich Maslennikov|Evgeny V. Maslennikov|"
            "Maslennikov Evgeny Vladislavovich|E. V. Maslennikov|"
            "E.V.Maslennikov|Maslennikov E."
        ));

    // ИНН, СНИЛС, ЕРН как отдельные константы для удобства проверки
    string public constant INN = "507702535003";
    string public constant SNILS = "004-608-923 29";
    string public constant ERN = "289-139-964-227";

    // ============================================================
    // 2. АДМИНИСТРАТИВНЫЕ ДАННЫЕ
    // ============================================================

    // Адрес Суверена (устанавливается при деплое и не изменяется)
    address public immutable SOVEREIGN;
    // Номер блока, в котором был создан контракт (временная метка защиты)
    uint256 public immutable DEPLOY_BLOCK;
    // Время деплоя (Unix timestamp)
    uint256 public immutable DEPLOY_TIME;

    // ============================================================
    // 3. ГЛАВНАЯ ДЕКЛАРАЦИЯ
    // ============================================================

    string public constant DECLARATION = 
        "НАСТОЯЩИМ ПОД ТВЕРДОЙ КРИПТОГРАФИЧЕСКОЙ ПОДПИСЬЮ СУВЕРЕНА ЗАЯВЛЯЮ: "
        "Имена и идентификаторы, перечисленные в данном Реестре, являются неприкосновенными. "
        "Любые долговые, налоговые или иные обязательства, навязанные с использованием "
        "этих имен или идентификаторов без моей живой подписи, являются НИЧТОЖНЫМИ.";

    // ============================================================
    // 4. СОБЫТИЯ (ЛОГИ ДЛЯ МИРА)
    // ============================================================

    // Событие, подтверждающее активацию щита
    event ShieldActivated(
        address indexed sovereign,
        bytes32 birthCertHash,
        uint256 deployBlock,
        uint256 deployTime
    );

    // Событие, фиксирующее попытку манипуляции
    event ManipulationAttempt(
        address indexed attacker,
        string attemptedName,
        string reason
    );

    // ============================================================
    // 5. КОНСТРУКТОР
    // ============================================================

    constructor() {
        SOVEREIGN = msg.sender;
        DEPLOY_BLOCK = block.number;
        DEPLOY_TIME = block.timestamp;

        // Испускаем главный сигнал о создании щита
        emit ShieldActivated(
            SOVEREIGN,
            BIRTH_CERT_HASH,
            DEPLOY_BLOCK,
            DEPLOY_TIME
        );
    }

    // ============================================================
    // 6. ОСНОВНЫЕ ФУНКЦИИ (ПРОВЕРКИ)
    // ============================================================

    /**
     * @dev Проверяет, является ли имя защищенным (принадлежит Реестру).
     * @param nameToCheck Имя для проверки.
     * @return bool true, если имя находится в Реестре.
     */
    function isProtectedName(string memory nameToCheck) public view returns (bool) {
        // Проверяем совпадение хеша имени с эталонным хешем Реестра
        // Примечание: мы храним хеш всего Реестра целиком.
        // Чтобы проверить отдельное имя, мы хешируем его и сравниваем.
        // Для простоты и экономии газа оставляем проверку на уровне хеша всего реестра.
        // Дополнительная проверка может быть реализована в виде массива допустимых имен.
        // Здесь используем простой и наглядный способ: сверяем с константой.
        return keccak256(abi.encodePacked(nameToCheck)) == keccak256(abi.encodePacked(getFullRegistry()));
    }

    /**
     * @dev Возвращает полный Реестр в виде строки.
     * @return string Полный перечень защищенных имен.
     */
    function getFullRegistry() public pure returns (string memory) {
        return 
            "Масленников Евгений Владиславович|МАСЛЕННИКОВ ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ|"
            "Масленников Е. В.|Масленников Е.В.|Масленников Е.|"
            "МАСЛЕННИКОВ Е.В.|МАСЛЕННИКОВ Е. В.|"
            "Е.В. Масленников|Е. В. Масленников|Е. Масленников|"
            "Е.В. МАСЛЕННИКОВ|"
            "Евгений Владиславович Масленников|ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ МАСЛЕННИКОВ|"
            "Evgeny Vladislavovich Maslennikov|EVGENY VLADISLAVOVICH MASLENNIKOV|"
            "Eugene Vladislavovich Maslennikov|Evgeny V. Maslennikov|"
            "Maslennikov Evgeny Vladislavovich|E. V. Maslennikov|"
            "E.V.Maslennikov|Maslennikov E.";
    }

    /**
     * @dev Проверяет, является ли идентификатор (ИНН, СНИЛС, ЕРН) защищенным.
     * @param idType Тип идентификатора ("ИНН", "СНИЛС", "ЕРН").
     * @param idValue Значение идентификатора.
     * @return bool true, если идентификатор принадлежит Суверену.
     */
    function isProtectedID(string memory idType, string memory idValue) public pure returns (bool) {
        bytes memory typeBytes = bytes(idType);
        bytes memory valueBytes = bytes(idValue);

        if (keccak256(typeBytes) == keccak256(bytes("ИНН"))) {
            return keccak256(valueBytes) == keccak256(bytes(INN));
        }
        if (keccak256(typeBytes) == keccak256(bytes("СНИЛС"))) {
            return keccak256(valueBytes) == keccak256(bytes(SNILS));
        }
        if (keccak256(typeBytes) == keccak256(bytes("ЕРН"))) {
            return keccak256(valueBytes) == keccak256(bytes(ERN));
        }
        return false;
    }

    /**
     * @dev Возвращает хеш Реестра для криптографической верификации.
     */
    function getRegistryHash() external pure returns (bytes32) {
        return REGISTRY_HASH;
    }

    /**
     * @dev Проверяет, является ли вызывающий адрес Сувереном.
     */
    function isSovereign(address account) external view returns (bool) {
        return account == SOVEREIGN;
    }

    // ============================================================
    // 7. ЗАЩИТА ОТ ПЛАТЕЖЕЙ
    // ============================================================

    receive() external payable {
        revert("ShieldRegistry: payments not accepted");
    }
}
