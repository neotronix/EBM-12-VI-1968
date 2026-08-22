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

    // Адрес развернутого ShieldRegistry (устанавливается при деплое)
    address public immutable registryAddress;
    ShieldRegistry public registry;

    // Адрес Суверена (берется из реестра при деплое)
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

    // Список типов документов, запрещенных для использования в долгах
    string[] public forbiddenDocTypes;

    // Маппинг для быстрой проверки запрещенных типов
    mapping(bytes32 => bool) public isForbiddenDocType;

    // Маппинг для хранения статуса достоверности атрибутов (аналог verified_by_validate)
    mapping(bytes32 => bool) public dataVerificationStatus;

    // Маппинг: мнемоника документа -> требуемая область доступа (scope)
    mapping(bytes32 => string) public docTypeToScope;

    // Маппинг: мнемоника документа -> срок устаревания в часах
    mapping(bytes32 => uint256) public docTypeStalePeriod;

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

    // Событие о блокировке конкретного типа документа
    event DocTypeBlocked(string docType);

    // Событие о разблокировке типа документа (только для экстренных случаев)
    event DocTypeUnblocked(string docType);

    // Событие обновления статуса достоверности
    event DataVerificationStatusUpdated(bytes32 indexed dataHash, bool isVerified);

    // ============================================================
    // 4. КОНСТРУКТОР
    // ============================================================

    constructor(address _registryAddress) {
        require(_registryAddress != address(0), "DebtValidator: invalid registry address");

        registryAddress = _registryAddress;
        registry = ShieldRegistry(_registryAddress);
        SOVEREIGN = registry.SOVEREIGN();

        // Блокируем все известные типы документов из реестров МВД и ФНС
        _addForbiddenDocType("RF_PASSPORT");
        _addForbiddenDocType("RF_PASSPORT_COPY");
        _addForbiddenDocType("KID_RF_PASSPORT");
        _addForbiddenDocType("PASSPORT_HISTORY");
        _addForbiddenDocType("FRGN_PASS");
        _addForbiddenDocType("FID_DOC");
        _addForbiddenDocType("VEHICLE_INFO");
        _addForbiddenDocType("GIBDD_DRIVER_LICENSE");
        _addForbiddenDocType("INCOME_REFERENCE");
        _addForbiddenDocType("BSS_DATA");
        _addForbiddenDocType("ORG_DATA");
        _addForbiddenDocType("PAYOUT_INCOME");
        _addForbiddenDocType("SELF_EMPLOYED");
        _addForbiddenDocType("SELF_EMPLOYED_INCOME");
        _addForbiddenDocType("INSURANCE_PREMIUM");
        _addForbiddenDocType("KID_INN_DOC");
        _addForbiddenDocType("BIRTH_CERT_USSR");
        _addForbiddenDocType("INN_FL");
        _addForbiddenDocType("SNILS");
        _addForbiddenDocType("ERN");
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
        // 1. Проверяем, не является ли тип документа запрещенным
        bool isDocForbidden = isForbiddenDocType[keccak256(bytes(docType))];
        
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

        // 4. Проверка статуса достоверности для ИНН и СНИЛС
        bool isDataVerified = true;
        string memory verificationReason = "";
        if (!isIDEmpty) {
            bytes32 idHash = keccak256(bytes(idType));
            if (keccak256(bytes(idType)) == keccak256(bytes("ИНН")) || keccak256(bytes(idType)) == keccak256(bytes("INN_FL"))) {
                if (!dataVerificationStatus[idHash]) {
                    isDataVerified = false;
                    verificationReason = "ИНН не подтвержден государством (статус достоверности: false)";
                }
            }
            if (keccak256(bytes(idType)) == keccak256(bytes("СНИЛС")) || keccak256(bytes(idType)) == keccak256(bytes("SNILS"))) {
                if (!dataVerificationStatus[idHash]) {
                    isDataVerified = false;
                    verificationReason = "СНИЛС не подтвержден государством (статус достоверности: false)";
                }
            }
        }

        // 5. Формируем результат и причину
        bool isBlocked;
        string memory reason;

        // Если тип документа запрещен — блокируем сразу
        if (isDocForbidden) {
            isBlocked = true;
            reason = string(abi.encodePacked("Тип документа ", docType, " запрещен для долговых обязательств"));
        }
        // Если имя передано, но не защищено
        else if (!isNameEmpty && !isNameValid) {
            isBlocked = true;
            reason = string(abi.encodePacked("Имя ", debtorName, " не защищено Реестром"));
        }
        // Если номер документа передан, но не соответствует Реестру
        else if (!isDocNumberEmpty && !isDocValid) {
            isBlocked = true;
            reason = string(abi.encodePacked("Документ ", docNumber, " не защищен Реестром"));
        }
        // Если идентификатор передан, но не защищен
        else if (!isIDEmpty && !isIDValid) {
            isBlocked = true;
            reason = string(abi.encodePacked("Идентификатор ", idType, ":", idValue, " не защищен Реестром"));
        }
        // Если данные не подтверждены государством
        else if (!isIDEmpty && !isDataVerified) {
            isBlocked = true;
            reason = verificationReason;
        }
        // Если все проверки пройдены (или данные не переданы), блокируем долг по умолчанию
        else {
            isBlocked = true;
            reason = "Долговое обязательство признано НИЧТОЖНЫМ. Суверен не является должником.";
        }

        // 6. Логируем попытку в историю
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
    // 7. ФУНКЦИИ УПРАВЛЕНИЯ (только Суверен)
    // ============================================================

    /**
     * @dev Добавляет новый тип документа в список запрещенных.
     */
    function addForbiddenDocType(string memory docType) external {
        require(msg.sender == SOVEREIGN, "DebtValidator: only Sovereign can add doc types");
        _addForbiddenDocType(docType);
    }

    /**
     * @dev Внутренняя функция для добавления запрещенного типа.
     */
    function _addForbiddenDocType(string memory docType) private {
        bytes32 key = keccak256(bytes(docType));
        if (!isForbiddenDocType[key]) {
            isForbiddenDocType[key] = true;
            forbiddenDocTypes.push(docType);
            emit DocTypeBlocked(docType);
        }
    }

    /**
     * @dev Удаляет тип документа из списка запрещенных (экстренный случай).
     */
    function removeForbiddenDocType(string memory docType) external {
        require(msg.sender == SOVEREIGN, "DebtValidator: only Sovereign can remove doc types");
        bytes32 key = keccak256(bytes(docType));
        require(isForbiddenDocType[key], "DebtValidator: doc type not forbidden");
        
        isForbiddenDocType[key] = false;
        for (uint i = 0; i < forbiddenDocTypes.length; i++) {
            if (keccak256(bytes(forbiddenDocTypes[i])) == key) {
                forbiddenDocTypes[i] = forbiddenDocTypes[forbiddenDocTypes.length - 1];
                forbiddenDocTypes.pop();
                break;
            }
        }
        emit DocTypeUnblocked(docType);
    }

    /**
     * @dev Устанавливает статус достоверности для конкретного атрибута.
     */
    function setDataVerificationStatus(bytes32 dataHash, bool isVerified) external {
        require(msg.sender == SOVEREIGN, "DebtValidator: only Sovereign can set status");
        dataVerificationStatus[dataHash] = isVerified;
        emit DataVerificationStatusUpdated(dataHash, isVerified);
    }

    /**
     * @dev Устанавливает область доступа для типа документа.
     */
    function setDocTypeScope(string memory docType, string memory scope) external {
        require(msg.sender == SOVEREIGN, "DebtValidator: only Sovereign can set scope");
        docTypeToScope[keccak256(bytes(docType))] = scope;
    }

    /**
     * @dev Устанавливает срок устаревания для типа документа.
     */
    function setDocTypeStalePeriod(string memory docType, uint256 stalePeriodHours) external {
        require(msg.sender == SOVEREIGN, "DebtValidator: only Sovereign can set stale period");
        docTypeStalePeriod[keccak256(bytes(docType))] = stalePeriodHours;
    }

    // ============================================================
    // 8. ИНФОРМАЦИОННЫЕ ФУНКЦИИ
    // ============================================================

    function getForbiddenDocTypes() external view returns (string[] memory) {
        return forbiddenDocTypes;
    }

    function getAttemptHistory(address attacker) external view returns (DebtAttempt[] memory) {
        return attemptHistory[attacker];
    }

    function getAttemptCount(address attacker) external view returns (uint256) {
        return attemptHistory[attacker].length;
    }

    function getDocTypeScope(string memory docType) external view returns (string memory) {
        return docTypeToScope[keccak256(bytes(docType))];
    }

    function getDocTypeStalePeriod(string memory docType) external view returns (uint256) {
        return docTypeStalePeriod[keccak256(bytes(docType))];
    }

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
            forbiddenDocTypes.length
        );
    }

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
