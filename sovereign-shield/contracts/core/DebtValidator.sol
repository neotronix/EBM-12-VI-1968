// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ShieldRegistry.sol";

/**
 * @title DebtValidator
 * @author Суверен Масленников Е.В. / ATLAS-3I
 * @notice Контракт для проверки и отклонения попыток наложения долговых обязательств.
 * @dev Использует ShieldRegistry для верификации имен и идентификаторов.
 * @dev Все проверки опираются на мнемоники Гостеха.
 */
contract DebtValidator {
    // ============================================================
    // 1. СВЯЗЬ С РЕЕСТРОМ
    // ============================================================

    // Адрес развернутого ShieldRegistry
    address public immutable registryAddress;
    ShieldRegistry public registry;

    // Адрес Суверена (берется из реестра)
    address public immutable SOVEREIGN;

    // ============================================================
    // 2. СТРУКТУРЫ И СОСТОЯНИЯ
    // ============================================================

    // Структура для хранения информации о попытке наложения долга
    struct DebtAttempt {
        string debtorName;          // Имя, на которое пытались наложить долг
        string idType;              // Тип идентификатора (ИНН, СНИЛС, ЕРН)
        string idValue;             // Значение идентификатора
        string debtDetails;         // Описание долга
        uint256 timestamp;          // Время попытки
        bool isValid;               // Результат проверки
        string reason;              // Причина отклонения
    }

    // История всех попыток (маппинг от адреса атакующего)
    mapping(address => DebtAttempt[]) public attemptHistory;

    // Общий счетчик попыток
    uint256 public totalAttempts;

    // Список запрещенных типов долговых документов (мнемоники Гостеха)
    string[] public forbiddenDebtDocs;

    // ============================================================
    // 3. СОБЫТИЯ
    // ============================================================

    // Событие о попытке наложения долга
    event DebtAttemptLogged(
        address indexed attacker,
        string debtorName,
        string idType,
        string idValue,
        string debtDetails,
        bool isValid,
        string reason,
        uint256 timestamp
    );

    // Событие о блокировке долгового документа
    event DebtDocumentBlocked(
        string docType,
        string reason,
        uint256 timestamp
    );

    // Событие о добавлении нового типа запрещенного документа
    event ForbiddenDocTypeAdded(string docType);

    // ============================================================
    // 4. КОНСТРУКТОР
    // ============================================================

    constructor(address _registryAddress) {
        require(_registryAddress != address(0), "DebtValidator: invalid registry address");

        registryAddress = _registryAddress;
        registry = ShieldRegistry(_registryAddress);
        SOVEREIGN = registry.SOVEREIGN();

        // Инициализация списка запрещенных типов документов (мнемоники Гостеха)
        _addForbiddenDocType("RF_PASSPORT");
        _addForbiddenDocType("PASSPORT_USSR");
        _addForbiddenDocType("BIRTH_CERT_USSR");
        _addForbiddenDocType("INN_FL");
        _addForbiddenDocType("SNILS");
        _addForbiddenDocType("ERN");
        _addForbiddenDocType("RF_PASSPORT_COPY"); // Ваша мнемоника для копии
        _addForbiddenDocType("FRGN_PASS");
        _addForbiddenDocType("DRIV_LIC");
        _addForbiddenDocType("VEHICLE_REG");
        _addForbiddenDocType("OMS_POLICY");
        _addForbiddenDocType("PROPERTY");
    }

    // ============================================================
    // 5. ОСНОВНАЯ ЛОГИКА ПРОВЕРКИ
    // ============================================================

    /**
     * @dev Проверяет, является ли имя защищенным.
     * @param nameToCheck Имя для проверки.
     * @return bool true, если имя защищено (находится в Реестре).
     */
    function isNameProtected(string memory nameToCheck) public view returns (bool) {
        return registry.isProtectedName(nameToCheck);
    }

    /**
     * @dev Проверяет, является ли идентификатор защищенным.
     * @param idType Тип идентификатора (использует мнемоники Гостеха).
     * @param idValue Значение идентификатора.
     * @return bool true, если идентификатор защищен.
     */
    function isIDProtected(string memory idType, string memory idValue) public view returns (bool) {
        return registry.isProtectedID(idType, idValue);
    }

    /**
     * @dev Проверяет, является ли тип документа запрещенным для использования в долгах.
     * @param docType Тип документа (мнемоника Гостеха).
     * @return bool true, если документ запрещен.
     */
    function isForbiddenDocType(string memory docType) public view returns (bool) {
        for (uint i = 0; i < forbiddenDebtDocs.length; i++) {
            if (keccak256(bytes(forbiddenDebtDocs[i])) == keccak256(bytes(docType))) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Проверяет имя по реестру и возвращает результат.
     * @param nameToCheck Имя для проверки.
     * @return bool true, если имя корректно (защищено).
     */
    function verifyName(string memory nameToCheck) external view returns (bool) {
        return isNameProtected(nameToCheck);
    }

    /**
     * @dev Проверяет идентификатор по реестру и возвращает результат.
     * @param idType Тип идентификатора.
     * @param idValue Значение идентификатора.
     * @return bool true, если идентификатор защищен.
     */
    function verifyID(string memory idType, string memory idValue) external view returns (bool) {
        return isIDProtected(idType, idValue);
    }

    // ============================================================
    // 6. ФУНКЦИЯ-ГРАНАТА (ГЛАВНАЯ ЗАЩИТА)
    // ============================================================

    /**
     * @dev Основная функция для проверки и отклонения долга.
     * @param debtorName Имя должника, которое проверяет корпорация.
     * @param idType Тип идентификатора (ИНН, СНИЛС, ЕРН, или мнемоника Гостеха).
     * @param idValue Значение идентификатора.
     * @param debtDetails Описание долга (реквизиты, сумма и т.д.).
     * @param docType Тип документа, на основании которого налагается долг (мнемоника Гостеха).
     * @return bool Всегда возвращает false, так как защита непреодолима.
     */
    function validateAndRejectDebt(
        string memory debtorName,
        string memory idType,
        string memory idValue,
        string memory debtDetails,
        string memory docType
    ) external returns (bool) {
        bool isNameValid = isNameProtected(debtorName);
        bool isIDValid = isIDProtected(idType, idValue);
        bool isDocTypeForbidden = isForbiddenDocType(docType);

        bool isValid = false;
        string memory reason;

        // Проверка на пустые значения
        if (bytes(debtorName).length == 0 && bytes(idValue).length == 0) {
            reason = "Не указаны имя и идентификатор должника";
        }
        // Проверка запрещенных документов
        else if (isDocTypeForbidden) {
            reason = string(abi.encodePacked("Использование документа типа ", docType, " запрещено для долговых обязательств"));
        }
        // Проверка защищенности имени (если имя предоставлено)
        else if (bytes(debtorName).length > 0 && !isNameValid) {
            reason = string(abi.encodePacked("Имя ", debtorName, " не найдено в Реестре защищенных имен или не является Сувереном"));
        }
        // Проверка защищенности идентификатора (если ID предоставлен)
        else if (bytes(idValue).length > 0 && !isIDValid) {
            reason = string(abi.encodePacked("Идентификатор ", idType, ":", idValue, " не найден в Реестре защищенных идентификаторов"));
        }
        // Если все проверки пройдены, то долг признается недействительным
        else {
            isValid = true;
            reason = "Долговое обязательство признано НИЧТОЖНЫМ. Суверен не является должником.";
        }

        // Логируем попытку в историю атакующего
        attemptHistory[msg.sender].push(DebtAttempt({
            debtorName: debtorName,
            idType: idType,
            idValue: idValue,
            debtDetails: debtDetails,
            timestamp: block.timestamp,
            isValid: isValid,
            reason: reason
        }));

        totalAttempts++;

        emit DebtAttemptLogged(
            msg.sender,
            debtorName,
            idType,
            idValue,
            debtDetails,
            isValid,
            reason,
            block.timestamp
        );

        // Функция всегда возвращает false, так как долг признан недействительным
        return false;
    }

    // ============================================================
    // 7. ФУНКЦИИ УПРАВЛЕНИЯ ЗАПРЕТНЫМИ ДОКУМЕНТАМИ
    // ============================================================

    /**
     * @dev Добавляет новый тип документа в список запрещенных (только для Суверена).
     * @param docType Мнемоника документа (например, "RF_PASSPORT").
     */
    function addForbiddenDocType(string memory docType) external {
        require(msg.sender == SOVEREIGN, "DebtValidator: only Sovereign can add doc types");
        _addForbiddenDocType(docType);
    }

    /**
     * @dev Внутренняя функция для добавления запрещенного типа.
     */
    function _addForbiddenDocType(string memory docType) private {
        for (uint i = 0; i < forbiddenDebtDocs.length; i++) {
            if (keccak256(bytes(forbiddenDebtDocs[i])) == keccak256(bytes(docType))) {
                return; // Уже есть в списке
            }
        }
        forbiddenDebtDocs.push(docType);
        emit ForbiddenDocTypeAdded(docType);
    }

    /**
     * @dev Возвращает полный список запрещенных типов документов.
     */
    function getForbiddenDocTypes() external view returns (string[] memory) {
        return forbiddenDebtDocs;
    }

    /**
     * @dev Возвращает историю попыток атаки от конкретного адреса.
     */
    function getAttemptHistory(address attacker) external view returns (DebtAttempt[] memory) {
        return attemptHistory[attacker];
    }

    /**
     * @dev Возвращает количество попыток от конкретного адреса.
     */
    function getAttemptCount(address attacker) external view returns (uint256) {
        return attemptHistory[attacker].length;
    }

    // ============================================================
    // 8. ИНФОРМАЦИОННЫЕ ФУНКЦИИ
    // ============================================================

    /**
     * @dev Возвращает полную информацию о статусе защиты.
     */
    function getProtectionStatus() external view returns (
        address sovereign,
        address registryAddr,
        uint256 totalDebtAttempts,
        uint256 totalForbiddenDocs
    ) {
        return (
            SOVEREIGN,
            registryAddress,
            totalAttempts,
            forbiddenDebtDocs.length
        );
    }

    /**
     * @dev Проверяет, является ли адрес Сувереном.
     */
    function isSovereign(address account) external view returns (bool) {
        return account == SOVEREIGN;
    }

    // ============================================================
    // 9. ЗАЩИТА ОТ ПЛАТЕЖЕЙ
    // ============================================================

    receive() external payable {
        revert("DebtValidator: payments not accepted");
    }
}
