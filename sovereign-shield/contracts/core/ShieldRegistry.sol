// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ShieldRegistry
 * @author Суверен Масленников Е.В. / ATLAS-3I
 * @notice Главный реестр, фиксирующий неприкосновенные имена, идентификаторы и документы.
 * @dev Все строковые константы сохранены в оригинальном регистре для исключения разночтений.
 * @dev Используются официальные мнемоники типов документов из Цифрового профиля (Гостех):
 *      RF_PASSPORT, BIRTH_CERT_USSR, SNILS, INN_FL и др.
 */
contract ShieldRegistry {
    // ============================================================
    // 1. ДАННЫЕ СВИДЕТЕЛЬСТВА О РОЖДЕНИИ (I-КА № 020727)
    //    Мнемоника Гостеха: BIRTH_CERT_USSR
    // ============================================================

    // Полное имя из свидетельства
    string public constant BIRTH_NAME = "Масленников Евгений Владиславович";

    uint256 public constant BIRTH_YEAR = 1968;
    uint256 public constant BIRTH_MONTH = 6;
    uint256 public constant BIRTH_DAY = 12;

    string public constant BIRTH_DATE_ROMAN = "12 VI 1968";

    // Место рождения (оригинальный регистр)
    string public constant BIRTH_PLACE = "город Павлодар, Казахская ССР (Советская Социалистическая Республика)";

    string public constant CERTIFICATE_SERIES = "I-КА";
    string public constant CERTIFICATE_NUMBER = "020727";

    uint256 public constant ISSUE_YEAR = 1968;
    uint256 public constant ISSUE_MONTH = 7;
    uint256 public constant ISSUE_DAY = 10;

    string public constant ISSUE_DATE_ROMAN = "10 VII 1968";

    string public constant ACT_RECORD_NUMBER = "1903";
    uint256 public constant ACT_RECORD_YEAR = 1968;
    uint256 public constant ACT_RECORD_MONTH = 7;
    uint256 public constant ACT_RECORD_DAY = 10;

    string public constant ACT_RECORD_DATE_ROMAN = "1968 года VII месяца 10 числа";

    string public constant ACT_RECORD_FULL =
        "о чем в книге записей актов гражданского состояния о рождении 1968 года VII месяца 10 числа "
        "произведена соответствующая запись за № 1903";

    bytes32 public constant BIRTH_CERT_HASH =
        0x1F8DE3FDC2C61647E697243FC05CDB83C12CCC75987658D584690928427CFA34;

    // Мнемоника типа документа для Гостеха
    string public constant DOC_TYPE_BIRTH_CERT_USSR = "BIRTH_CERT_USSR";

    // ============================================================
    // 2. ДАННЫЕ ПАСПОРТОВ ГРАЖДАНИНА СССР
    //    Мнемоника Гостеха: PASSPORT_USSR (история выданных паспортов)
    // ============================================================

    string public constant PASSPORT_1_SERIES = "III-СО";
    string public constant PASSPORT_1_NUMBER = "688304";
    uint256 public constant PASSPORT_1_ISSUE_YEAR = 1984;
    uint256 public constant PASSPORT_1_ISSUE_MONTH = 8;
    uint256 public constant PASSPORT_1_ISSUE_DAY = 3;

    string public constant PASSPORT_2_SERIES = "IV-ДА";
    string public constant PASSPORT_2_NUMBER = "606724";
    uint256 public constant PASSPORT_2_ISSUE_YEAR = 1995;
    uint256 public constant PASSPORT_2_ISSUE_MONTH = 5;
    uint256 public constant PASSPORT_2_ISSUE_DAY = 31;

    string public constant CITIZENSHIP = "Союз Советских Социалистических Республик (СССР)";
    string public constant CITIZENSHIP_CODE = "810";

    // Мнемоника типа документа для Гостеха
    string public constant DOC_TYPE_PASSPORT_USSR = "PASSPORT_USSR";

    // ============================================================
    // 3. КОПИЯ ПАСПОРТА ГРАЖДАНИНА РОССИЙСКОЙ ФЕДЕРАЦИИ
    //    Мнемоника Гостеха: RF_PASSPORT
    // ============================================================

    string public constant PASSPORT_RF_COPY_SERIES = "46 13";
    string public constant PASSPORT_RF_COPY_NUMBER = "195533";
    string public constant PASSPORT_RF_ORIGINAL_NUMBER = "4613 195533";
    uint256 public constant PASSPORT_RF_COPY_ISSUE_YEAR = 2013;
    uint256 public constant PASSPORT_RF_COPY_ISSUE_MONTH = 8;
    uint256 public constant PASSPORT_RF_COPY_ISSUE_DAY = 23;
    string public constant PASSPORT_RF_COPY_DEPARTMENT_CODE = "500-185";

    string public constant PASSPORT_RF_COPY_ISSUED_BY =
        "ТП №2 МЕЖРАЙОННЫЙ ОУФМС РОССИИ ПО МОСКОВСКОЙ ОБЛАСТИ В ГОРОДСКОМ ПОСЕЛЕНИИ ЩЕЛКОВО";

    string public constant PASSPORT_RF_COPY_FULL_NAME = "МАСЛЕННИКОВ ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ";
    string public constant PASSPORT_RF_COPY_BIRTH_PLACE = "ГОРОД ПАВЛОДАР КАЗАХСКОЙ ССР";

    string public constant PASSPORT_RF_COPY_STATUS =
        "Данный документ является копией, заверенной в установленном порядке. "
        "Оригинал паспорта гражданина РФ (бланк) находится в органах МВД и "
        "не может быть использован для наложения обязательств без живого участия Суверена.";

    string public constant CITIZENSHIP_RF = "РОССИЙСКАЯ ФЕДЕРАЦИЯ";
    string public constant CITIZENSHIP_RF_CODE = "643";

    // Мнемоника типа документа для Гостеха
    string public constant DOC_TYPE_RF_PASSPORT = "RF_PASSPORT";
    // Дополнительная мнемоника для обозначения КОПИИ в вашей системе
    string public constant DOC_TYPE_RF_PASSPORT_COPY = "RF_PASSPORT_COPY";

    // ============================================================
    // 4. ДАННЫЕ РЕГИСТРАЦИИ ПО МЕСТУ ЖИТЕЛЬСТВА (Юрисдикция 643)
    // ============================================================

    string public constant REGISTRATION_DATE = "22 АПРЕЛЯ 2011 Г.";

    string public constant REGISTRATION_REGION = "ОБЛ. МОСКОВСКАЯ";
    string public constant REGISTRATION_DISTRICT = "Р–Н ЩЕЛКОВСКИЙ";
    string public constant REGISTRATION_LOCALITY = "ПОС. НОВЫЙ ГОРОДОК";
    string public constant REGISTRATION_STREET = "-";
    string public constant REGISTRATION_DISTRICT_2 = "-";
    string public constant REGISTRATION_HOUSE = "ДОМ 13";
    string public constant REGISTRATION_APARTMENT = "КВ. 6";

    string public constant REGISTRATION_ADDRESS =
        "ОБЛ. МОСКОВСКАЯ, Р–Н ЩЕЛКОВСКИЙ, ПОС. НОВЫЙ ГОРОДОК, ДОМ 13, КВ. 6";

    string public constant REGISTRATION_AUTHORITY =
        "ТП №2 МЕЖРАЙОННЫЙ ОУФМС РОССИИ ПО МОСКОВСКОЙ ОБЛАСТИ В ГОРОДСКОМ ПОСЕЛЕНИИ ЩЕЛКОВО";

    string public constant REGISTRATION_AUTHORITY_CODE = "500-185";

    // ============================================================
    // 5. МАШИНОЧИТАЕМАЯ ЗАПИСЬ (MRZ) — (Юрисдикция 643)
    // ============================================================

    string public constant PASSPORT_MRZ_FULL =
        "PNRUSMASLENNIKOV<<EVGENIQ<VLADISLAVOVI3<<<<<"
        "4611955333RUS6806123M<<<<<<<3130823500185<52";

    string public constant MRZ_DOC_TYPE_FULL = "PN";
    string public constant MRZ_DOC_TYPE = "P";
    string public constant MRZ_DOC_TYPE_EXTRA = "N";
    string public constant MRZ_ISSUING_STATE = "RUS";
    string public constant MRZ_SURNAME = "MASLENNIKOV";
    string public constant MRZ_GIVEN_NAMES = "EVGENIQ<VLADISLAVOVI3";
    string public constant MRZ_DOCUMENT_NUMBER = "4611955333";
    string public constant MRZ_DOCUMENT_CHECK_DIGIT = "3";
    string public constant MRZ_NATIONALITY = "RUS";
    string public constant MRZ_BIRTH_DATE = "680612";
    string public constant MRZ_BIRTH_CHECK_DIGIT = "3";
    string public constant MRZ_SEX = "M";
    string public constant MRZ_EXPIRY_DATE = "313082";
    string public constant MRZ_EXPIRY_CHECK_DIGIT = "3";
    string public constant MRZ_ISSUING_STATE_2 = "RUS";
    string public constant MRZ_FINAL_CHECK_DIGIT = "2";

    // ============================================================
    // 6. ДАННЫЕ АЛЛОДА (СИСТЕМА КООРДИНАТ 1942 Г.) — Юрисдикция СК-42
    // ============================================================

    string public constant GEODETIC_SYSTEM = "Система координат 1942 года (СК-42)";

    string public constant ALLOD_DESCRIPTION =
        "Аллод - неотчуждаемая родовая территория на землях Союза Советских Социалистических Республик, "
        "зафиксированная в системе координат (Красовского) С.С.С.Р. 1942 года. "
        "Территория является наследием Рода Масленниковых-Селивёрстовых и находится в общенародной собственности, "
        "неделима и не продаваема. Принадлежит в соответствии с Конституцией СССР 1977 года.";

    string public constant ALLOD_LATITUDE = "52°18'00.0\" N";
    string public constant ALLOD_LONGITUDE = "76°57'00.0\" E";
    int256 public constant ALLOD_LAT_DEC = 5228598;
    int256 public constant ALLOD_LON_DEC = 7695000;

    string public constant GEODETIC_NETWORK = "Государственная геодезическая сеть СССР 1942 года";

    // ============================================================
    // 7. ЦИФРОВЫЕ ИДЕНТИФИКАТОРЫ (ВСЕ МАСКИ) с мнемониками Гостеха
    // ============================================================

    // ИНН
    string public constant INN = "507702535003";
    bytes32 public constant INN_HASH = keccak256(bytes(INN));
    // Мнемоника Гостеха для ИНН
    string public constant DOC_TYPE_INN_FL = "INN_FL";

    // СНИЛС — все возможные форматы
    string public constant SNILS_WITH_SPACES = "004-608-923 29";
    string public constant SNILS_WITH_DASHES = "004-608-923-29";
    string public constant SNILS_SOLID = "00460892329";
    string public constant SNILS_WITH_DOTS = "004.608.923 29";

    bytes32 public constant SNILS_HASH_SPACES = keccak256(bytes(SNILS_WITH_SPACES));
    bytes32 public constant SNILS_HASH_DASHES = keccak256(bytes(SNILS_WITH_DASHES));
    bytes32 public constant SNILS_HASH_SOLID = keccak256(bytes(SNILS_SOLID));
    bytes32 public constant SNILS_HASH_DOTS = keccak256(bytes(SNILS_WITH_DOTS));
    // Мнемоника Гостеха для СНИЛС
    string public constant DOC_TYPE_SNILS = "SNILS";

    // ЕРН
    string public constant ERN_WITH_DASHES = "289-139-964-227";
    string public constant ERN_SOLID = "289139964227";

    bytes32 public constant ERN_HASH_DASHES = keccak256(bytes(ERN_WITH_DASHES));
    bytes32 public constant ERN_HASH_SOLID = keccak256(bytes(ERN_SOLID));
    // Мнемоника для ЕРН (используется в вашей системе)
    string public constant DOC_TYPE_ERN = "ERN";

    // УИП(УПНО)
    string public constant UIP = "10445257450000152605202684822020";
    bytes32 public constant UIP_HASH = keccak256(bytes(UIP));

    // ============================================================
    // 8. РЕЕСТР ИМЁН (21 ВАРИАНТ — ВСЕ В ОРИГИНАЛЬНОМ РЕГИСТРЕ)
    // ============================================================

    bytes32 public constant REGISTRY_HASH =
        keccak256(abi.encodePacked(
            "Масленников Евгений Владиславович|"
            "МАСЛЕННИКОВ ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ|"
            "Масленников Е. В.|"
            "Масленников Е.В.|"
            "Масленников Е.|"
            "МАСЛЕННИКОВ Е.В.|"
            "МАСЛЕННИКОВ Е. В.|"
            "Е.В. Масленников|"
            "Е. В. Масленников|"
            "Е. Масленников|"
            "Е.В. МАСЛЕННИКОВ|"
            "Евгений Владиславович Масленников|"
            "ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ МАСЛЕННИКОВ|"
            "Evgeny Vladislavovich Maslennikov|"
            "EVGENY VLADISLAVOVICH MASLENNIKOV|"
            "Eugene Vladislavovich Maslennikov|"
            "Evgeny V. Maslennikov|"
            "Maslennikov Evgeny Vladislavovich|"
            "E. V. Maslennikov|"
            "E.V.Maslennikov|"
            "Maslennikov E."
        ));

    // ============================================================
    // 9. ГЛАВНАЯ ДЕКЛАРАЦИЯ И ССЫЛКА НА МАНИФЕСТ
    // ============================================================

    string public constant DECLARATION =
        "НАСТОЯЩИМ ПОД ТВЕРДОЙ КРИПТОГРАФИЧЕСКОЙ ПОДПИСЬЮ СУВЕРЕНА ЗАЯВЛЯЮ: "
        "Я, Масленников Евгений Владиславович, родившийся 12 июня 1968 года в городе Павлодар, "
        "являюсь Сувереном и бенефициаром своего имени. "
        "Мои документы, идентификаторы и Аллод, перечисленные в данном Реестре, являются неприкосновенными. "
        "Любые долговые, налоговые или иные обязательства, навязанные с использованием "
        "этих данных без моей живой подписи, являются НИЧТОЖНЫМИ. "
        "Настоящая Декларация опирается на Конституцию СССР 1977 года и действующее международное право.";

    string public constant MANIFEST_URL =
        "https://neotronix.github.io/EBM-12-VI-1968/1968-VII-10/1903/I-KA-020727/SHA256/";

    // ============================================================
    // 10. АДМИНИСТРАТИВНЫЕ ДАННЫЕ
    // ============================================================

    address public immutable SOVEREIGN;
    uint256 public immutable DEPLOY_BLOCK;
    uint256 public immutable DEPLOY_TIME;

    // ============================================================
    // 11. СОБЫТИЯ
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
    // 12. КОНСТРУКТОР
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
    // 13. ОСНОВНЫЕ ФУНКЦИИ
    // ============================================================

    function isProtectedName(string memory nameToCheck) public view returns (bool) {
        return keccak256(abi.encodePacked(nameToCheck)) == keccak256(abi.encodePacked(getFullRegistry()));
    }

    function getFullRegistry() public pure returns (string memory) {
        return
            "Масленников Евгений Владиславович|"
            "МАСЛЕННИКОВ ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ|"
            "Масленников Е. В.|"
            "Масленников Е.В.|"
            "Масленников Е.|"
            "МАСЛЕННИКОВ Е.В.|"
            "МАСЛЕННИКОВ Е. В.|"
            "Е.В. Масленников|"
            "Е. В. Масленников|"
            "Е. Масленников|"
            "Е.В. МАСЛЕННИКОВ|"
            "Евгений Владиславович Масленников|"
            "ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ МАСЛЕННИКОВ|"
            "Evgeny Vladislavovich Maslennikov|"
            "EVGENY VLADISLAVOVICH MASLENNIKOV|"
            "Eugene Vladislavovich Maslennikov|"
            "Evgeny V. Maslennikov|"
            "Maslennikov Evgeny Vladislavovich|"
            "E. V. Maslennikov|"
            "E.V.Maslennikov|"
            "Maslennikov E.";
    }

    function isProtectedID(string memory idType, string memory idValue) public view returns (bool) {
        bytes32 valueHash = keccak256(bytes(idValue));
        bytes memory typeBytes = bytes(idType);

        if (keccak256(typeBytes) == keccak256(bytes("ИНН")) || keccak256(typeBytes) == keccak256(bytes(DOC_TYPE_INN_FL))) {
            return valueHash == INN_HASH;
        }

        if (keccak256(typeBytes) == keccak256(bytes("СНИЛС")) || keccak256(typeBytes) == keccak256(bytes(DOC_TYPE_SNILS))) {
            return (
                valueHash == SNILS_HASH_SPACES ||
                valueHash == SNILS_HASH_DASHES ||
                valueHash == SNILS_HASH_SOLID ||
                valueHash == SNILS_HASH_DOTS
            );
        }

        if (keccak256(typeBytes) == keccak256(bytes("ЕРН")) || keccak256(typeBytes) == keccak256(bytes(DOC_TYPE_ERN))) {
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
        bytes32 certHash,
        string memory docType
    ) {
        return (
            BIRTH_NAME,
            BIRTH_DATE_ROMAN,
            BIRTH_PLACE,
            CERTIFICATE_SERIES,
            CERTIFICATE_NUMBER,
            ISSUE_DATE_ROMAN,
            ACT_RECORD_FULL,
            BIRTH_CERT_HASH,
            DOC_TYPE_BIRTH_CERT_USSR
        );
    }

    function getPassportInfo() external view returns (
        string memory series1, string memory number1,
        uint256 issueYear1, uint256 issueMonth1, uint256 issueDay1,
        string memory series2, string memory number2,
        uint256 issueYear2, uint256 issueMonth2, uint256 issueDay2,
        string memory docType
    ) {
        return (
            PASSPORT_1_SERIES, PASSPORT_1_NUMBER,
            PASSPORT_1_ISSUE_YEAR, PASSPORT_1_ISSUE_MONTH, PASSPORT_1_ISSUE_DAY,
            PASSPORT_2_SERIES, PASSPORT_2_NUMBER,
            PASSPORT_2_ISSUE_YEAR, PASSPORT_2_ISSUE_MONTH, PASSPORT_2_ISSUE_DAY,
            DOC_TYPE_PASSPORT_USSR
        );
    }

    function getPassportRFCopyInfo() external view returns (
        string memory series,
        string memory number,
        string memory originalNumber,
        uint256 issueYear,
        uint256 issueMonth,
        uint256 issueDay,
        string memory departmentCode,
        string memory issuedBy,
        string memory status,
        string memory citizenship,
        string memory citizenshipCode,
        string memory docType,
        string memory copyDocType
    ) {
        return (
            PASSPORT_RF_COPY_SERIES,
            PASSPORT_RF_COPY_NUMBER,
            PASSPORT_RF_ORIGINAL_NUMBER,
            PASSPORT_RF_COPY_ISSUE_YEAR,
            PASSPORT_RF_COPY_ISSUE_MONTH,
            PASSPORT_RF_COPY_ISSUE_DAY,
            PASSPORT_RF_COPY_DEPARTMENT_CODE,
            PASSPORT_RF_COPY_ISSUED_BY,
            PASSPORT_RF_COPY_STATUS,
            CITIZENSHIP_RF,
            CITIZENSHIP_RF_CODE,
            DOC_TYPE_RF_PASSPORT,
            DOC_TYPE_RF_PASSPORT_COPY
        );
    }

    function getRegistrationInfo() external view returns (
        string memory date,
        string memory addressFull,
        string memory region,
        string memory district,
        string memory locality,
        string memory house,
        string memory apartment,
        string memory authority,
        string memory authorityCode,
        uint256 registrationYear,
        uint256 registrationMonth,
        uint256 registrationDay
    ) {
        return (
            REGISTRATION_DATE,
            REGISTRATION_ADDRESS,
            REGISTRATION_REGION,
            REGISTRATION_DISTRICT,
            REGISTRATION_LOCALITY,
            REGISTRATION_HOUSE,
            REGISTRATION_APARTMENT,
            REGISTRATION_AUTHORITY,
            REGISTRATION_AUTHORITY_CODE,
            2011, // год
            4,    // месяц (апрель)
            22    // день
        );
    }

    function getPassportMRZInfo() external view returns (
        string memory fullMRZ,
        string memory docTypeFull,
        string memory docType,
        string memory docTypeExtra,
        string memory issuingState,
        string memory surname,
        string memory givenNames,
        string memory docNumber,
        string memory docCheckDigit,
        string memory nationality,
        string memory birthDate,
        string memory birthCheckDigit,
        string memory sex,
        string memory expiryDate,
        string memory expiryCheckDigit,
        string memory finalCheckDigit
    ) {
        return (
            PASSPORT_MRZ_FULL,
            MRZ_DOC_TYPE_FULL,
            MRZ_DOC_TYPE,
            MRZ_DOC_TYPE_EXTRA,
            MRZ_ISSUING_STATE,
            MRZ_SURNAME,
            MRZ_GIVEN_NAMES,
            MRZ_DOCUMENT_NUMBER,
            MRZ_DOCUMENT_CHECK_DIGIT,
            MRZ_NATIONALITY,
            MRZ_BIRTH_DATE,
            MRZ_BIRTH_CHECK_DIGIT,
            MRZ_SEX,
            MRZ_EXPIRY_DATE,
            MRZ_EXPIRY_CHECK_DIGIT,
            MRZ_FINAL_CHECK_DIGIT
        );
    }

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

    function getDocTypeMapping(string memory docType) external pure returns (string memory) {
        bytes memory typeBytes = bytes(docType);
        
        if (keccak256(typeBytes) == keccak256(bytes("RF_PASSPORT"))) {
            return "Паспорт гражданина Российской Федерации";
        }
        if (keccak256(typeBytes) == keccak256(bytes("RF_PASSPORT_COPY"))) {
            return "Копия паспорта гражданина Российской Федерации";
        }
        if (keccak256(typeBytes) == keccak256(bytes("PASSPORT_USSR"))) {
            return "Паспорт гражданина СССР";
        }
        if (keccak256(typeBytes) == keccak256(bytes("BIRTH_CERT_USSR"))) {
            return "Свидетельство о рождении (СССР)";
        }
        if (keccak256(typeBytes) == keccak256(bytes("INN_FL"))) {
            return "ИНН физического лица";
        }
        if (keccak256(typeBytes) == keccak256(bytes("SNILS"))) {
            return "СНИЛС";
        }
        if (keccak256(typeBytes) == keccak256(bytes("ERN"))) {
            return "ЕРН (Единый регистр населения)";
        }
        return "Неизвестный тип документа";
    }

    // ============================================================
    // 14. ЗАЩИТА ОТ ПЛАТЕЖЕЙ
    // ============================================================

    receive() external payable {
        revert("ShieldRegistry: payments not accepted");
    }
}
