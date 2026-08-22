// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ShieldRegistry.sol";
import "./DocTypeRegistry.sol";

/**
 * @title DebtValidator
 * @author Суверен Масленников Е.В. / ATLAS-3I
 * @notice Контракт для проверки и отклонения попыток наложения долговых обязательств.
 * @dev Использует ShieldRegistry для верификации имен и идентификаторов.
 * @dev Использует DocTypeRegistry для получения параметров типов документов.
 */
contract DebtValidator {
    // ============================================================
    // 1. СВЯЗЬ С РЕЕСТРАМИ
    // ============================================================

    // Адрес развернутого ShieldRegistry
    address public immutable registryAddress;
    ShieldRegistry public registry;

    // Адрес развернутого DocTypeRegistry
    address public immutable docTypeRegistryAddress;
    DocTypeRegistry public docTypeRegistry;

    // Адрес Суверена (берется из ShieldRegistry при деплое)
    address public immutable SOVEREIGN;

    // ============================================================
    // 2. СТРУКТУРЫ ДАННЫХ
    // ============================================================

    // Структура для хранения информации о каждой попытке
    struct DebtAttempt {
        string debtorName;          // Имя, на которое пытались наложить долг
        string docType;             // Тип документа (мнемоника Гостеха)
        string docNumber;           // Номер документа (если указан)
        string idType;              // Тип идентификатора (ИНН, СНИЛС, ЕРН)
        string idValue;             // Значение идентификатора
        string debtDetails;         // Детали долга (сумма, основание и т.д.)
        uint256 timestamp;          // Время попытки
        bool isBlocked;             // Результат: заблокирован ли долг
        string reason;              // Причина блокировки или отказа
    }

    // История попыток для каждого адреса
    mapping(address => DebtAttempt[]) public attemptHistory;

    // Общий счетчик всех попыток
    uint256 public totalAttempts;

    // ============================================================
    // 3. СОБЫТИЯ
    // ============================================================

    // Событие о попытке наложения долга (основной лог)
    event DebtAttemptLogged(
        address indexed attacker,
        string debtorName,
        string docType,
        string docNumber,
        string idType,
        string idValue,
        string debtDetails,
        bool isBlocked,
        string reason,
        uint256 timestamp
    );

    // ============================================================
    // 4. КОНСТРУКТОР
    // ============================================================

    constructor(address _registryAddress, address _docTypeRegistryAddress) {
        require(_registryAddress != address(0), "DebtValidator: invalid registry address");
        require(_docTypeRegistryAddress != address(0), "DebtValidator: invalid doc type registry address");

        registryAddress = _registryAddress;
        registry = ShieldRegistry(_registryAddress);
        SOVEREIGN = registry.SOVEREIGN();

        docTypeRegistryAddress = _docTypeRegistryAddress;
        docTypeRegistry = DocTypeRegistry(_docTypeRegistryAddress);
    }

    // ============================================================
    // 5. ОСНОВНАЯ ЛОГИКА ПРОВЕРКИ
    // ============================================================

    /**
     * @dev Проверяет, защищено ли имя (находится в Реестре).
     */
    function isNameProtected(string memory nameToCheck) public view returns (bool) {
        return registry.isProtectedName(nameToCheck);
    }

    /**
     * @dev Проверяет, защищен ли идентификатор.
     */
    function isIDProtected(string memory idType, string memory idValue) public view returns (bool) {
        return registry.isProtectedID(idType, idValue);
    }

    /**
     * @dev Проверяет, защищен ли номер документа (для загранпаспорта).
     */
    function isValidForeignPassportNumber(string memory passportNumber) public view returns (bool) {
        (bool success, bytes memory data) = registryAddress.staticcall(
            abi.encodeWithSignature("isValidForeignPassportNumber(string)", passportNumber)
        );
        if (success && data.length == 32) {
            return abi.decode(data, (bool));
        }
        return false;
    }

    /**
     * @dev Проверяет, является ли вариант свидетельства допустимым.
     */
    function isValidCertificateVariant(string memory certString) public view returns (bool) {
        (bool success, bytes memory data) = registryAddress.staticcall(
            abi.encodeWithSignature("isValidCertificateVariant(string)", certString)
        );
        if (success && data.length == 32) {
            return abi.decode(data, (bool));
        }
        return false;
    }

    /**
     * @dev Проверяет, является ли вариант паспорта СССР допустимым.
     */
    function isValidPassport2Variant(string memory passportString) public view returns (bool) {
        (bool success, bytes memory data) = registryAddress.staticcall(
            abi.encodeWithSignature("isValidPassport2Variant(string)", passportString)
        );
        if (success && data.length == 32) {
            return abi.decode(data, (bool));
        }
        return false;
    }

    // ============================================================
    // 6. ГЛАВНАЯ ФУНКЦИЯ ЗАЩИТЫ
    // ============================================================

    /**
     * @dev Основная функция для проверки и отклонения долга.
     * @param debtorName Имя должника (может быть пустым).
     * @param docType Тип документа (мнемоника Гостеха).
     * @param docNumber Номер документа (может быть пустым).
     * @param idType Тип идентификатора (ИНН, СНИЛС, ЕРН).
     * @param idValue Значение идентификатора (может быть пустым).
     * @param debtDetails Детали долга (сумма, основание и т.д.).
     * @return bool Всегда возвращает false, так как защита непреодолима.
     */
    function validateAndRejectDebt(
        string memory debtorName,
        string memory docType,
        string memory docNumber,
        string memory idType,
        string memory idValue,
        string memory debtDetails
    ) external returns (bool) {
        // 1. Проверяем, не является ли тип документа запрещенным через реестр
        (bool isDocForbidden, , ) = docTypeRegistry.getDocTypeInfo(docType);
        
        // 2. Проверяем, не пустые ли поля (если переданы)
        bool isNameEmpty = bytes(debtorName).length == 0;
        bool isDocNumberEmpty = bytes(docNumber).length == 0;
        bool isIDEmpty = bytes(idValue).length == 0;
        
        // 3. Проверяем соответствие реестру (если данные переданы)
        bool isNameValid = !isNameEmpty && isNameProtected(debtorName);
        bool isDocValid = !isDocNumberEmpty && (
            isValidForeignPassportNumber(docNumber) ||
            isValidCertificateVariant(docNumber) ||
            isValidPassport2Variant(docNumber)
        );
        bool isIDValid = !isIDEmpty && isIDProtected(idType, idValue);

        // 4. Формируем результат и причину
        bool isBlocked;
        string memory reason;

        // Если тип документа запрещен — блокируем сразу
        if (isDocForbidden) {
            isBlocked = true;
            reason = string(abi.encodePacked(
                "Тип документа ", docType, " запрещен для долговых обязательств"
            ));
        }
        // Если имя передано, но не защищено
        else if (!isNameEmpty && !isNameValid) {
            isBlocked = true;
            reason = string(abi.encodePacked(
                "Имя ", debtorName, " не защищено Реестром"
            ));
        }
        // Если номер документа передан, но не соответствует Реестру
        else if (!isDocNumberEmpty && !isDocValid) {
            isBlocked = true;
            reason = string(abi.encodePacked(
                "Документ ", docNumber, " не защищен Реестром"
            ));
        }
        // Если идентификатор передан, но не защищен
        else if (!isIDEmpty && !isIDValid) {
            isBlocked = true;
            reason = string(abi.encodePacked(
                "Идентификатор ", idType, ":", idValue, " не защищен Реестром"
            ));
        }
        // Если все проверки пройдены (или данные не переданы), блокируем долг по умолчанию
        else {
            isBlocked = true;
            reason = "Долговое обязательство признано НИЧТОЖНЫМ. Суверен не является должником.";
        }

        // 5. Логируем попытку в историю
        attemptHistory[msg.sender].push(DebtAttempt({
            debtorName: debtorName,
            docType: docType,
            docNumber: docNumber,
            idType: idType,
            idValue: idValue,
            debtDetails: debtDetails,
            timestamp: block.timestamp,
            isBlocked: isBlocked,
            reason: reason
        }));

        totalAttempts++;

        emit DebtAttemptLogged(
            msg.sender,
            debtorName,
            docType,
            docNumber,
            idType,
            idValue,
            debtDetails,
            isBlocked,
            reason,
            block.timestamp
        );

        // Всегда возвращаем false, так как долг признан недействительным
        return false;
    }

    // ============================================================
    // 7. ИНФОРМАЦИОННЫЕ ФУНКЦИИ
    // ============================================================

    /**
     * @dev Возвращает историю попыток по адресу.
     */
    function getAttemptHistory(address attacker) external view returns (DebtAttempt[] memory) {
        return attemptHistory[attacker];
    }

    /**
     * @dev Возвращает количество попыток по адресу.
     */
    function getAttemptCount(address attacker) external view returns (uint256) {
        return attemptHistory[attacker].length;
    }

    /**
     * @dev Возвращает статус защиты.
     */
    function getProtectionStatus() external view returns (
        address sovereign,
        address registryAddr,
        address docTypeRegistryAddr,
        uint256 totalDebtAttempts
    ) {
        return (
            SOVEREIGN,
            registryAddress,
            docTypeRegistryAddress,
            totalAttempts
        );
    }

    /**
     * @dev Проверяет, является ли адрес Сувереном.
     */
    function isSovereign(address account) external view returns (bool) {
        return account == SOVEREIGN;
    }

    // ============================================================
    // 8. ЗАЩИТА ОТ ПЛАТЕЖЕЙ
    // ============================================================

    receive() external payable {
        revert("DebtValidator: payments not accepted");
    }
}
