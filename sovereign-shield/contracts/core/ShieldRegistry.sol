// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ShieldRegistry
 * @author Суверен Масленников Е.В. / ATLAS-3I
 * @notice Главный реестр, фиксирующий неприкосновенные имена, идентификаторы, данные свидетельства и Аллод.
 * @dev Включает полные данные свидетельства о рождении с римскими цифрами, паспорта СССР, УИП и систему координат СК-42.
 */
contract ShieldRegistry {
    // ============================================================
    // 1. ДАННЫЕ СВИДЕТЕЛЬСТВА О РОЖДЕНИИ (I-КА № 020727)
    // ============================================================

    // Полное имя из свидетельства
    string public constant BIRTH_NAME = "Масленников Евгений Владиславович";

    // Дата рождения (арабские цифры — для машинной обработки)
    uint256 public constant BIRTH_YEAR = 1968;
    uint256 public constant BIRTH_MONTH = 6;   // Июнь
    uint256 public constant BIRTH_DAY = 12;

    // Дата рождения (римские цифры — для точного соответствия тексту свидетельства)
    string public constant BIRTH_DATE_ROMAN = "12 VI 1968";

    // Место рождения (полное соответствие свидетельству)
    string public constant BIRTH_PLACE = "город Павлодар, Казахская ССР (Советская Социалистическая Республика)";

    // Данные свидетельства
    string public constant CERTIFICATE_SERIES = "I-КА";
    string public constant CERTIFICATE_NUMBER = "020727";

    // Дата выдачи (арабские цифры)
    uint256 public constant ISSUE_YEAR = 1968;
    uint256 public constant ISSUE_MONTH = 7;   // Июль
    uint256 public constant ISSUE_DAY = 10;

    // Дата выдачи (римские цифры — для точного соответствия тексту свидетельства)
    string public constant ISSUE_DATE_ROMAN = "10 VII 1968";

    // Запись акта о рождении № 1903
    string public constant ACT_RECORD_NUMBER = "1903";
    uint256 public constant ACT_RECORD_YEAR = 1968;
    uint256 public constant ACT_RECORD_MONTH = 7;
    uint256 public constant ACT_RECORD_DAY = 10;

    // Запись акта о рождении (римские цифры — для точного соответствия тексту свидетельства)
    string public constant ACT_RECORD_DATE_ROMAN = "1968 года VII месяца 10 числа";

    // Полная строка записи акта — для максимальной точности
    string public constant ACT_RECORD_FULL = 
        "о чем в книге записей актов гражданского состояния о рождении 1968 года VII месяца 10 числа "
        "произведена соответствующая запись за № 1903";

    // RWA SHA256 хеш оригинала свидетельства
    bytes32 public constant BIRTH_CERT_HASH = 
        0x1F8DE3FDC2C61647E697243FC05CDB83C12CCC75987658D584690928427CFA34;

    // ============================================================
    // 2. ДАННЫЕ ПАСПОРТОВ ГРАЖДАНИНА СССР
    // ============================================================

    // Паспорт СССР (выдан 3 августа 1984 года)
    string public constant PASSPORT_1_SERIES = "III-СО";
    string public constant PASSPORT_1_NUMBER = "688304";
    uint256 public constant PASSPORT_1_ISSUE_YEAR = 1984;
    uint256 public constant PASSPORT_1_ISSUE_MONTH = 8;
    uint256 public constant PASSPORT_1_ISSUE_DAY = 3;

    // Паспорт СССР (выдан 31 мая 1995 года)
    string public constant PASSPORT_2_SERIES = "IV-ДА";
    string public constant PASSPORT_2_NUMBER = "606724";
    uint256 public constant PASSPORT_2_ISSUE_YEAR = 1995;
    uint256 public constant PASSPORT_2_ISSUE_MONTH = 5;
    uint256 public constant PASSPORT_2_ISSUE_DAY = 31;

    // Гражданство (код страны 810 SUR)
    string public constant CITIZENSHIP = "Союз Советских Социалистических Республик (СССР)";
    string public constant CITIZENSHIP_CODE = "810";

    // ============================================================
    // 3. ДАННЫЕ АЛЛОДА (СИСТЕМА КООРДИНАТ 1942 Г.)
    // ============================================================

    // Название геодезической системы
    string public constant GEODETIC_SYSTEM = "Система координат 1942 года (СК-42)";

    // Описание аллода
    string public constant ALLOD_DESCRIPTION = 
        "Аллод - неотчуждаемая родовая территория на землях Союза Советских Социалистических Республик, "
        "зафиксированная в системе координат (Красовского) С.С.С.Р. 1942 года. "
        "Территория является наследием Рода Масленниковых-Селивёрстовых и находится в общенародной собственности, "
        "неделима и не продаваема. Принадлежит в соответствии с Конституцией СССР 1977 года.";

    // Географические координаты (Центральная точка вашего Аллода - Павлодар, Казахская ССР)
    // Значения указаны в градусах, минутах, секундах, а также в десятичном формате
    // для совместимости с различными геоинформационными системами.
    string public constant ALLOD_LATITUDE = "52°18'00.0\" N"; // Пример для Павлодара
    string public constant ALLOD_LONGITUDE = "76°57'00.0\" E"; // Пример для Павлодара

    // Координаты в десятичных градусах (для машинной обработки)
    int256 public constant ALLOD_LAT_DEC = 5228598; // 52°18'00.0" N в десятичных градусах * 1e5
    int256 public constant ALLOD_LON_DEC = 7695000; // 76°57'00.0" E в десятичных градусах * 1e5

    // Ссылка на геодезическую сеть (если есть)
    string public constant GEODETIC_NETWORK = "Государственная геодезическая сеть СССР 1942 года";

    // Дополнительная метка времени (дата фиксации аллода)
    uint256 public constant ALLOD_RECORD_YEAR = 2024;
    uint256 public constant ALLOD_RECORD_MONTH = 8;
    uint256 public constant ALLOD_RECORD_DAY = 24;

    // ============================================================
    // 4. ЦИФРОВЫЕ ИДЕНТИФИКАТОРЫ (ВСЕ МАСКИ)
    // ============================================================

    // ИНН
    string public constant INN = "507702535003";
    bytes32 public constant INN_HASH = keccak256(bytes(INN));

    // СНИЛС — все возможные форматы
    string public constant SNILS_WITH_SPACES = "004-608-923 29";
    string public constant SNILS_WITH_DASHES = "004-608-923-29";
    string public constant SNILS_SOLID = "00460892329";
    string public constant SNILS_WITH_DOTS = "004.608.923 29";
    
    bytes32 public constant SNILS_HASH_SPACES = keccak256(bytes(SNILS_WITH_SPACES));
    bytes32 public constant SNILS_HASH_DASHES = keccak256(bytes(SNILS_WITH_DASHES));
    bytes32 public constant SNILS_HASH_SOLID = keccak256(bytes(SNILS_SOLID));
    bytes32 public constant SNILS_HASH_DOTS = keccak256(bytes(SNILS_WITH_DOTS));

    // ЕРН — все возможные форматы
    string public constant ERN_WITH_DASHES = "289-139-964-227";
    string public constant ERN_SOLID = "289139964227";
    
    bytes32 public constant ERN_HASH_DASHES = keccak256(bytes(ERN_WITH_DASHES));
    bytes32 public constant ERN_HASH_SOLID = keccak256(bytes(ERN_SOLID));

    // УИП(УПНО) из вашего манифеста
    string public constant UIP = "10445257450000152605202684822020";
    bytes32 public constant UIP_HASH = keccak256(bytes(UIP));

    // ============================================================
    // 5. РЕЕСТР ИМЁН (21 ВАРИАНТ)
    // ============================================================

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

    // ============================================================
    // 6. ГЛАВНАЯ ДЕКЛАРАЦИЯ И ССЫЛКА НА МАНИФЕСТ
    // ============================================================

    string public constant DECLARATION = 
        "НАСТОЯЩИМ ПОД ТВЕРДОЙ КРИПТОГРАФИЧЕСКОЙ ПОДПИСЬЮ СУВЕРЕНА ЗАЯВЛЯЮ: "
        "Я, Масленников Евгений Владиславович, родившийся 12 июня 1968 года в городе Павлодар, "
        "являюсь Сувереном и бенефициаром своего имени. "
        "Мои паспортные данные, идентификаторы и Аллод, перечисленные в данном Реестре, являются неприкосновенными. "
        "Любые долговые, налоговые или иные обязательства, навязанные с использованием "
        "этих данных без моей живой подписи, являются НИЧТОЖНЫМИ. "
        "Настоящая Декларация опирается на Конституцию СССР 1977 года и действующее международное право.";

    // Ссылка на публичный манифест
    string public constant MANIFEST_URL = 
        "https://neotronix.github.io/EBM-12-VI-1968/1968-VII-10/1903/I-KA-020727/SHA256/";

    // ============================================================
    // 7. АДМИНИСТРАТИВНЫЕ ДАННЫЕ
    // ============================================================

    address public immutable SOVEREIGN;
    uint256 public immutable DEPLOY_BLOCK;
    uint256 public immutable DEPLOY_TIME;

    // ============================================================
    // 8. СОБЫТИЯ
    // ============================================================

    event ShieldActivated(
        address indexed sovereign,
        bytes32 birthCertHash,
        uint256 deployBlock,
        uint256 deployTime
    );

    event ManipulationAttempt(
        address indexed attacker,
        string attemptedName,
        string reason
    );

    // ============================================================
    // 9. КОНСТРУКТОР
    // ============================================================

    constructor() {
        SOVEREIGN = msg.sender;
        DEPLOY_BLOCK = block.number;
        DEPLOY_TIME = block.timestamp;

        emit ShieldActivated(
            SOVEREIGN,
            BIRTH_CERT_HASH,
            DEPLOY_BLOCK,
            DEPLOY_TIME
        );
    }

    // ============================================================
    // 10. ОСНОВНЫЕ ФУНКЦИИ
    // ============================================================

    function isProtectedName(string memory nameToCheck) public view returns (bool) {
        return keccak256(abi.encodePacked(nameToCheck)) == keccak256(abi.encodePacked(getFullRegistry()));
    }

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

    function isProtectedID(string memory idType, string memory idValue) public view returns (bool) {
        bytes32 valueHash = keccak256(bytes(idValue));
        bytes memory typeBytes = bytes(idType);

        if (keccak256(typeBytes) == keccak256(bytes("ИНН"))) {
            return valueHash == INN_HASH;
        }

        if (keccak256(typeBytes) == keccak256(bytes("СНИЛС"))) {
            return (
                valueHash == SNILS_HASH_SPACES ||
                valueHash == SNILS_HASH_DASHES ||
                valueHash == SNILS_HASH_SOLID ||
                valueHash == SNILS_HASH_DOTS
            );
        }

        if (keccak256(typeBytes) == keccak256(bytes("ЕРН"))) {
            return (
                valueHash == ERN_HASH_DASHES ||
                valueHash == ERN_HASH_SOLID
            );
        }

        if (keccak256(typeBytes) == keccak256(bytes("УИП"))) {
            return valueHash == UIP_HASH;
        }

        return false;
    }

    function getBirthInfo() external view returns (
        string memory name,
        string memory birthDateRoman,
        string memory place,
        string memory certSeries,
        string memory certNumber,
        string memory issueDateRoman,
        string memory actRecordFull,
        bytes32 certHash
    ) {
        return (
            BIRTH_NAME,
            BIRTH_DATE_ROMAN,
            BIRTH_PLACE,
            CERTIFICATE_SERIES,
            CERTIFICATE_NUMBER,
            ISSUE_DATE_ROMAN,
            ACT_RECORD_FULL,
            BIRTH_CERT_HASH
        );
    }

    function getPassportInfo() external view returns (
        string memory series1, string memory number1,
        uint256 issueYear1, uint256 issueMonth1, uint256 issueDay1,
        string memory series2, string memory number2,
        uint256 issueYear2, uint256 issueMonth2, uint256 issueDay2
    ) {
        return (
            PASSPORT_1_SERIES, PASSPORT_1_NUMBER,
            PASSPORT_1_ISSUE_YEAR, PASSPORT_1_ISSUE_MONTH, PASSPORT_1_ISSUE_DAY,
            PASSPORT_2_SERIES, PASSPORT_2_NUMBER,
            PASSPORT_2_ISSUE_YEAR, PASSPORT_2_ISSUE_MONTH, PASSPORT_2_ISSUE_DAY
        );
    }

    /**
     * @dev Возвращает полную информацию об Аллоде.
     * @return geodeticSystem Название системы координат.
     * @return allodDescription Описание Аллода.
     * @return latitude Широта в формате градусов.
     * @return longitude Долгота в формате градусов.
     * @return latDec Широта в десятичных градусах (для машинной обработки).
     * @return lonDec Долгота в десятичных градусах (для машинной обработки).
     */
    function getAllodInfo() external view returns (
        string memory geodeticSystem,
        string memory allodDescription,
        string memory latitude,
        string memory longitude,
        int256 latDec,
        int256 lonDec
    ) {
        return (
            GEODETIC_SYSTEM,
            ALLOD_DESCRIPTION,
            ALLOD_LATITUDE,
            ALLOD_LONGITUDE,
            ALLOD_LAT_DEC,
            ALLOD_LON_DEC
        );
    }

    function getRegistryHash() external pure returns (bytes32) {
        return REGISTRY_HASH;
    }

    function isSovereign(address account) external view returns (bool) {
        return account == SOVEREIGN;
    }

    // ============================================================
    // 11. ЗАЩИТА ОТ ПЛАТЕЖЕЙ
    // ============================================================

    receive() external payable {
        revert("ShieldRegistry: payments not accepted");
    }
}
