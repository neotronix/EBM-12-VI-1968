// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ShieldRegistry
 * @author Суверен Масленников Е.В. / ATLAS-3I
 * @notice Главный реестр, фиксирующий неприкосновенные имена, идентификаторы и документы.
 * @dev Все строковые константы сохранены в оригинальном регистре для исключения разночтений.
 * @dev Используются официальные мнемоники типов документов из Цифрового профиля (Гостех).
 * @dev Связан с контрактом SovereignAllod для подтверждения суверенных прав.
 * @dev Включает поля для интеграции с государственными API (oid, статус достоверности).
 * @dev Хранит данные в двух форматах: оригинальном (римском) и формате Гостеха.
 * @dev Фиксирует статус Суверена как Первичного кредитора и конечного бенефициарного владельца.
 */
contract ShieldRegistry {
    // ============================================================
    // 0. ДЕКЛАРАЦИЯ СТАТУСА СУВЕРЕНА
    // ============================================================

    string public constant SOVEREIGN_STATUS = 
        "Евгений Владиславович Масленников-Селивёрстов"
        "гражданин Союза Советских Социалистических Республик"
        "Принято за ценность оригинальным первичным кредитором и конечным бенефициарным владельцем. "
        "Первичный кредитор евгений масленников. "
        "Конечный выгодоприобретатель (бенефициар) Евгений Владиславович Масленников.";

    // ============================================================
    // 1. ДАННЫЕ СВИДЕТЕЛЬСТВА О РОЖДЕНИИ (I-КА № 020727)
    //    Мнемоника Гостеха: OLD_BRTH_CERT / BIRTH_CERT_USSR
    // ============================================================

    // ---- Полная оригинальная формулировка (как в документе) ----
    string public constant BIRTH_RECORD_FULL = 
        "Масленников Евгений Владиславович родился 12 VI 1968 Двенадцатого июня тысяча девятьсот шестьдесят восьмого года, 
место рождения ребенка: город Павлодар, Казахская Советская Социалистическая Республика в составе Союза Советских Социалистических Республик (С.С.С.Р.), 
о чем в государственной книге записей актов гражданского состояния 1968 года VII месяца 10 числа произведена соответствующая запись акта о рождении за № 1903; 
Родители: 
отец Масленников Владислав Иванович родился 10 августа 1938 года, русский; 
мать Масленникова (Селивёрстова) Светлана Николаевна родилась 16 августа 1945 года, русская; 
свидетельство о рождении I-КА № 020727 выдано бюро записей актов гражданского состояния 10 VII 1968 года; 
Принято за ценность оригинальным первичным кредитором и конечным бенефициарным владельцем. 
Первичный кредитор евгений масленников. Конечный выгодоприобретатель (бенефициар) Евгений Владиславович Масленников.";

    // ---- Оригинальные данные (исторический формат) ----
    string public constant BIRTH_NAME = "Масленников Евгений Владиславович";
    uint256 public constant BIRTH_YEAR = 1968;
    uint256 public constant BIRTH_MONTH = 6;
    uint256 public constant BIRTH_DAY = 12;
    string public constant BIRTH_DATE_ROMAN = "12 VI 1968";
    string public constant BIRTH_DATE_FULL = "Двенадцатого июня тысяча девятьсот шестьдесят восьмого года";
    string public constant BIRTH_PLACE = "город Павлодар, Казахская Советская Социалистическая Республика в составе С.С.С.Р. (Союз Советских Социалистических Республик)";

    string public constant CERTIFICATE_SERIES = "I-КА";
    string public constant CERTIFICATE_NUMBER = "020727";
    string public constant ISSUE_DATE_ROMAN = "10 VII 1968";
    string public constant ACT_RECORD_DATE_ROMAN = "1968 года VII месяца 10 числа";
    string public constant ACT_RECORD_NUMBER = "1903";
    string public constant ACT_RECORD_FULL = 
        "о чем в государственной книге записей актов гражданского состояния 1968 года VII месяца 10 числа произведена соответствующая запись акта о рождении за № 1903";
    bytes32 public constant BIRTH_CERT_HASH = 0x1F8DE3FDC2C61647E697243FC05CDB83C12CCC75987658D584690928427CFA34;

    // ---- Данные для интеграции с Гостехом (формат API) ----
    string public constant BIRTH_CERT_TYPE = "OLD_BRTH_CERT";
    string public constant BIRTH_CERT_OID = "2080144827";
    string public constant BIRTH_CERT_ID = "1394776";
    string public constant BIRTH_CERT_RECEIPT_DATE = "1743530668830";
    string public constant BIRTH_CERT_RELEVANCE = "actual";
    string public constant BIRTH_CERT_STATUS = "unverified";
    string public constant BIRTH_CERT_DEPARTMENT = "Орган записи актов гражданского состояния";
    string public constant BIRTH_CERT_ISSUED_BY = "СССР";
    string public constant BIRTH_CERT_ISSUE_DATE = "10.07.1968";
    string public constant BIRTH_CERT_ACT_DATE = "10.07.1968";
    bool public constant BIRTH_CERT_ACT_FOUND = true;

    // ---- Мнемоника типа документа для Гостеха ----
    string public constant DOC_TYPE_BIRTH_CERT_USSR = "BIRTH_CERT_USSR";

    // ---- Все возможные варианты написания свидетельства I-КА 020727 ----
    string[] public constant CERTIFICATE_VARIANTS = [
        "I-КА 020727",
        "IКА 020727",
        "IКА020727",
        "ИКА020727",
        "ИКА 020727",
        "IKA020727",
        "IKA 020727"
    ];

    bytes32 public constant CERT_HASH_ORIGINAL = keccak256(bytes(CERTIFICATE_VARIANTS[0]));
    bytes32 public constant CERT_HASH_NO_DASH_SPACE_CYR = keccak256(bytes(CERTIFICATE_VARIANTS[1]));
    bytes32 public constant CERT_HASH_NO_DASH_NO_SPACE_CYR = keccak256(bytes(CERTIFICATE_VARIANTS[2]));
    bytes32 public constant CERT_HASH_RUS_A_NO_SPACE = keccak256(bytes(CERTIFICATE_VARIANTS[3]));
    bytes32 public constant CERT_HASH_RUS_A_SPACE = keccak256(bytes(CERTIFICATE_VARIANTS[4]));
    bytes32 public constant CERT_HASH_LAT_A_NO_SPACE = keccak256(bytes(CERTIFICATE_VARIANTS[5]));
    bytes32 public constant CERT_HASH_LAT_A_SPACE = keccak256(bytes(CERTIFICATE_VARIANTS[6]));

// ============================================================
    // 6. ДАННЫЕ АЛЛОДА (СИСТЕМА КООРДИНАТ 1942 Г.)
    // ============================================================

    string public constant GEODETIC_SYSTEM = "Система координат 1942 года (СК-42)";
    string public constant ALLOD_DESCRIPTION =
        "Аллод - неотчуждаемая родовая территория на землях Союза Советских Социалистических Республик, 
зафиксированная в системе координат (Красовского) С.С.С.Р. 1942 года. 
Территория является наследием Рода Масленниковых-Селивёрстовых, земля находится в общенародной собственности (всенародное достояние)
неделима и не продаваема, в соответствии с Конституцией (основной закон) Сoюзa Cовeтcких Социaлиcтичeских Реcпyблик 1936 года 
с обновлениями и дополнениями 1947 года.";
    string public constant ALLOD_LATITUDE = "52°18'00.0\" N";
    string public constant ALLOD_LONGITUDE = "76°57'00.0\" E";
    int256 public constant ALLOD_LAT_DEC = 5228598;
    int256 public constant ALLOD_LON_DEC = 7695000;
    string public constant GEODETIC_NETWORK = "Государственная геодезическая сеть С.С.С.Р. (Сoюз Cовeтcких Социaлиcтичeских Реcпyблик) 1942 года";

    // ============================================================
    // 2. ДАННЫЕ ПАСПОРТОВ ГРАЖДАНИНА СССР
    //    Мнемоника Гостеха: PASSPORT_HISTORY
    // ============================================================

    // ---- Оригинальные данные (исторический формат) ----
    // Паспорт СССР №1 (выдан 3 августа 1984 года)
    string public constant PASSPORT_1_SERIES = "III-СО";
    string public constant PASSPORT_1_NUMBER = "688304";
    uint256 public constant PASSPORT_1_ISSUE_YEAR = 1984;
    uint256 public constant PASSPORT_1_ISSUE_MONTH = 8;
    uint256 public constant PASSPORT_1_ISSUE_DAY = 3;

    // Паспорт СССР №2 (выдан 31 мая 1995 года)
    string public constant PASSPORT_2_SERIES = "IV-ДА";
    string public constant PASSPORT_2_NUMBER = "606724";
    uint256 public constant PASSPORT_2_ISSUE_YEAR = 1995;
    uint256 public constant PASSPORT_2_ISSUE_MONTH = 5;
    uint256 public constant PASSPORT_2_ISSUE_DAY = 31;

    // ---- Данные для интеграции с Гостехом (формат API) ----
    string public constant PASSPORT_1_TYPE = "ussr_passport";
    string public constant PASSPORT_1_ISSUE_DATE = "03.08.1984";
    string public constant PASSPORT_1_ISSUED_BY = "Главное управление МВД СССР";
    string public constant PASSPORT_1_STATUS = "noInformation";

    string public constant PASSPORT_2_TYPE = "ussr_passport";
    string public constant PASSPORT_2_ISSUE_DATE = "31.05.1995";
    string public constant PASSPORT_2_ISSUED_BY = ""Главное управление МВД СССР";
    string public constant PASSPORT_2_STATUS = "noInformation";

    // ---- Все возможные варианты написания паспорта №2 (IV-ДА 606724) ----
    string[] public constant PASSPORT_2_VARIANTS = [
        "IV-ДА 606724",
        "4ДА606724",
        "4DA606724",
        "4ДА 606724",
        "4DA 606724"
    ];

    bytes32 public constant PASSPORT_2_HASH_ORIGINAL = keccak256(bytes(PASSPORT_2_VARIANTS[0]));
    bytes32 public constant PASSPORT_2_HASH_NO_DASH_CYR = keccak256(bytes(PASSPORT_2_VARIANTS[1]));
    bytes32 public constant PASSPORT_2_HASH_NO_DASH_LAT = keccak256(bytes(PASSPORT_2_VARIANTS[2]));
    bytes32 public constant PASSPORT_2_HASH_SPACE_CYR = keccak256(bytes(PASSPORT_2_VARIANTS[3]));
    bytes32 public constant PASSPORT_2_HASH_SPACE_LAT = keccak256(bytes(PASSPORT_2_VARIANTS[4]));

    string public constant DOC_TYPE_PASSPORT_HISTORY = "PASSPORT_HISTORY";

    string public constant CITIZENSHIP = "Союз Советских Социалистических Республик (СССР)";
    string public constant CITIZENSHIP_CODE = "810";

    // ============================================================
    // 3. КОПИЯ ПАСПОРТА ГРАЖДАНИНА РОССИЙСКОЙ ФЕДЕРАЦИИ
    //    Мнемоника Гостеха: RF_PASSPORT
    // ============================================================

    // ---- Данные паспорта РФ (раздельно, как в API Госуслуг) ----
    string public constant PASSPORT_RF_SERIES = "4613";
    string public constant PASSPORT_RF_NUMBER = "195533";
    string public constant PASSPORT_RF_FULL_NUMBER = "4613 195533";
    string public constant PASSPORT_RF_FULL_NUMBER_SOLID = "4613195533";

    // ---- Данные для интеграции с Гостехом ----
    string public constant ESIA_OID = "";
    string public constant PASSPORT_RF_ISSUE_DATE = "23.08.2013";
    string public constant PASSPORT_RF_DEPARTMENT_CODE = "500-185";
    string public constant PASSPORT_RF_ISSUED_BY = "ТП №2 МЕЖРАЙОННЫЙ ОУФМС РОССИИ ПО МОСКОВСКОЙ ОБЛАСТИ В ГОРОДСКОМ ПОСЕЛЕНИИ ЩЕЛКОВО";
    string public constant PASSPORT_RF_STATUS = "verified_by_validate";
    string public constant PASSPORT_RF_RELEVANCE = "actual";
    string public constant PASSPORT_RF_DEPARTMENT_DOC = "ТП №2 МЕЖРАЙОННЫЙ ОУФМС РОССИИ ПО МОСКОВСКОЙ ОБЛАСТИ В ГОРОДСКОМ ПОСЕЛЕНИИ ЩЕЛКОВО";

    string public constant PASSPORT_RF_FULL_NAME = "МАСЛЕННИКОВ ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ";
    string public constant PASSPORT_RF_BIRTH_PLACE = "ГОРОД ПАВЛОДАР КАЗАХСКОЙ ССР";

    string public constant PASSPORT_RF_COPY_STATUS =
        "Данный документ является копией, заверенной в установленном порядке мастичной печатью для копий документов. "
        "Оригинал паспорта гражданина РФ (бланк) находится в форме 1П в органах МВД и "
        "не может быть использован для наложения обязательств без живого участия Суверена.";

    string public constant CITIZENSHIP_RF = "РОССИЙСКАЯ ФЕДЕРАЦИЯ";
    string public constant CITIZENSHIP_RF_CODE = "643";

    string public constant DOC_TYPE_RF_PASSPORT = "RF_PASSPORT";
    string public constant DOC_TYPE_RF_PASSPORT_COPY = "RF_PASSPORT_COPY";

    // ============================================================
    // 4. ДАННЫЕ РЕГИСТРАЦИИ ПО МЕСТУ ЖИТЕЛЬСТВА
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
    // 5. ДАННЫЕ ЗАГРАНИЧНОГО ПАСПОРТА
    // ============================================================

    string public constant FRGN_PASS_TYPE = "P";
    string public constant FRGN_PASS_ISSUING_STATE = "RUS";
    string public constant FRGN_PASS_NUMBER = "71 6238222";
    string public constant FRGN_PASS_NUMBER_SOLID = "716238222";
    string public constant FRGN_PASS_SURNAME = "MASLENNIKOV";
    string public constant FRGN_PASS_GIVEN_NAME = "EVGENY";
    uint256 public constant FRGN_PASS_ISSUE_YEAR = 2011;
    uint256 public constant FRGN_PASS_ISSUE_MONTH = 9;
    uint256 public constant FRGN_PASS_ISSUE_DAY = 23;
    string public constant FRGN_PASS_BIRTH_PLACE = "КАЗАХСТАН / USSR";
    string public constant FRGN_PASS_AUTHORITY = "ФМС 50022";

    string public constant FRGN_PASS_MRZ_FULL =
        "P<RUSMASLENNIKOV<<EVGENIY<<<<<<<<<<<<<<<<<<<<"
        "7162382221RUS6806123M2109239<<<<<<<<<<<<<<06";

    string public constant FRGN_MRZ_DOC_TYPE = "P";
    string public constant FRGN_MRZ_ISSUING_STATE = "RUS";
    string public constant FRGN_MRZ_SURNAME = "MASLENNIKOV";
    string public constant FRGN_MRZ_GIVEN_NAME = "EVGENIY";
    string public constant FRGN_MRZ_DOC_NUMBER = "716238222";
    string public constant FRGN_MRZ_CHECK_DIGIT = "1";
    string public constant FRGN_MRZ_NATIONALITY = "RUS";
    string public constant FRGN_MRZ_BIRTH_DATE = "680612";
    string public constant FRGN_MRZ_BIRTH_CHECK = "3";
    string public constant FRGN_MRZ_SEX = "M";
    string public constant FRGN_MRZ_EXPIRY_DATE = "210923";
    string public constant FRGN_MRZ_EXPIRY_CHECK = "9";
    string public constant FRGN_MRZ_FINAL_DIGIT = "6";

    string public constant DOC_TYPE_FRGN_PASS = "FRGN_PASS";

    // ============================================================
    // 7. ЦИФРОВЫЕ ИДЕНТИФИКАТОРЫ
    // ============================================================

    string public constant INN = "507702535003";
    bytes32 public constant INN_HASH = keccak256(bytes(INN));
    string public constant DOC_TYPE_INN_FL = "INN_FL";

    string public constant SNILS_WITH_SPACES = "004-608-923 29";
    string public constant SNILS_WITH_DASHES = "004-608-923-29";
    string public constant SNILS_SOLID = "00460892329";
    string public constant SNILS_WITH_DOTS = "004.608.923 29";

    bytes32 public constant SNILS_HASH_SPACES = keccak256(bytes(SNILS_WITH_SPACES));
    bytes32 public constant SNILS_HASH_DASHES = keccak256(bytes(SNILS_WITH_DASHES));
    bytes32 public constant SNILS_HASH_SOLID = keccak256(bytes(SNILS_SOLID));
    bytes32 public constant SNILS_HASH_DOTS = keccak256(bytes(SNILS_WITH_DOTS));
    string public constant DOC_TYPE_SNILS = "SNILS";

    string public constant ERN_WITH_DASHES = "289-139-964-227";
    string public constant ERN_SOLID = "289139964227";

    bytes32 public constant ERN_HASH_DASHES = keccak256(bytes(ERN_WITH_DASHES));
    bytes32 public constant ERN_HASH_SOLID = keccak256(bytes(ERN_SOLID));
    string public constant DOC_TYPE_ERN = "ERN";

    string public constant UIP = "10445257450000152605202684822020";
    bytes32 public constant UIP_HASH = keccak256(bytes(UIP));

    // ============================================================
    // 8. РЕЕСТР ИМЁН (21 ВАРИАНТ)
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
    // 9. ГЛАВНАЯ ДЕКЛАРАЦИЯ
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
    // 11. СВЯЗЬ С КОНТРАКТОМ SOVEREIGNALLOD
    // ============================================================

    address public sovereignAllodAddress;
    
    function setSovereignAllodAddress(address _sovereignAllodAddress) external {
        require(msg.sender == SOVEREIGN, "ShieldRegistry: only Sovereign can set address");
        sovereignAllodAddress = _sovereignAllodAddress;
    }

    function getSovereignAllodAddress() external view returns (address) {
        return sovereignAllodAddress;
    }

    // ============================================================
    // 12. СОБЫТИЯ
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

    event SovereignAllodLinked(address indexed sovereign, address allodAddress);

    // ============================================================
    // 13. КОНСТРУКТОР
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
    // 14. ОСНОВНЫЕ ФУНКЦИИ
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

    // ============================================================
    // 15. ФУНКЦИИ ДЛЯ РАБОТЫ С ВАРИАНТАМИ ДОКУМЕНТОВ
    // ============================================================

    function isValidCertificateVariant(string memory certString) public pure returns (bool) {
        bytes32 hash = keccak256(bytes(certString));
        return (
            hash == CERT_HASH_ORIGINAL ||
            hash == CERT_HASH_NO_DASH_SPACE_CYR ||
            hash == CERT_HASH_NO_DASH_NO_SPACE_CYR ||
            hash == CERT_HASH_RUS_A_NO_SPACE ||
            hash == CERT_HASH_RUS_A_SPACE ||
            hash == CERT_HASH_LAT_A_NO_SPACE ||
            hash == CERT_HASH_LAT_A_SPACE
        );
    }

    function getCertificateVariants() external pure returns (string[] memory) {
        return CERTIFICATE_VARIANTS;
    }

    function isValidPassport2Variant(string memory passportString) public pure returns (bool) {
        bytes32 hash = keccak256(bytes(passportString));
        return (
            hash == PASSPORT_2_HASH_ORIGINAL ||
            hash == PASSPORT_2_HASH_NO_DASH_CYR ||
            hash == PASSPORT_2_HASH_NO_DASH_LAT ||
            hash == PASSPORT_2_HASH_SPACE_CYR ||
            hash == PASSPORT_2_HASH_SPACE_LAT
        );
    }

    function getPassportVariants() external pure returns (string[] memory) {
        return PASSPORT_2_VARIANTS;
    }

    function isValidForeignPassportNumber(string memory passportNumber) public pure returns (bool) {
        bytes32 hash = keccak256(bytes(passportNumber));
        return (
            hash == keccak256(bytes(FRGN_PASS_NUMBER)) ||
            hash == keccak256(bytes(FRGN_PASS_NUMBER_SOLID))
        );
    }

    // ============================================================
    // 16. ЕДИНАЯ ЦЕПОЧКА ИДЕНТИЧНОСТИ
    // ============================================================

    struct IdentityChain {
        string sovereignStatus;
        string birthRecordFull;
        string name;
        string nameCaps;
        string nameLatin;
        string[] nameVariants;
        
        // Свидетельство о рождении (оригинал)
        string birthCertSeries;
        string birthCertNumber;
        string[] birthCertVariants;
        
        // Свидетельство о рождении (формат Гостеха)
        string birthCertType;
        string birthCertOid;
        string birthCertId;
        string birthCertStatus;
        
        // Паспорт СССР №1 (формат Гостеха)
        string passport1Type;
        string passport1Series;
        string passport1Number;
        string passport1IssueDate;
        string passport1IssuedBy;
        string passport1Status;
        
        // Паспорт СССР №2 (оригинал и формат Гостеха)
        string passport2Series;
        string passport2Number;
        string[] passport2Variants;
        string passport2Type;
        string passport2IssueDate;
        string passport2IssuedBy;
        string passport2Status;
        
        // Загранпаспорт
        string foreignPassportNumber;
        string foreignPassportNumberSolid;
        string foreignPassportSurname;
        string foreignPassportGivenName;
        
        // Паспорт РФ
        string passportRfSeries;
        string passportRfNumber;
        string passportRfFullNumber;
        string esiaOid;
        
        // Мнемоники
        string docTypeBirth;
        string docTypePassportHistory;
        string docTypeForeignPassport;
        string docTypeRfPassport;
        
        bytes32 identityHash;
    }

    function getIdentityChain() external pure returns (IdentityChain memory) {
        string[21] memory nameVariants = [
            "Масленников Евгений Владиславович",
            "МАСЛЕННИКОВ ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ",
            "Масленников Е. В.",
            "Масленников Е.В.",
            "Масленников Е.",
            "МАСЛЕННИКОВ Е.В.",
            "МАСЛЕННИКОВ Е. В.",
            "Е.В. Масленников",
            "Е. В. Масленников",
            "Е. Масленников",
            "Е.В. МАСЛЕННИКОВ",
            "Евгений Владиславович Масленников",
            "ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ МАСЛЕННИКОВ",
            "Evgeny Vladislavovich Maslennikov",
            "EVGENY VLADISLAVOVICH MASLENNIKOV",
            "Eugene Vladislavovich Maslennikov",
            "Evgeny V. Maslennikov",
            "Maslennikov Evgeny Vladislavovich",
            "E. V. Maslennikov",
            "E.V.Maslennikov",
            "Maslennikov E."
        ];

        string[] memory variants = new string[](21);
        for (uint i = 0; i < 21; i++) {
            variants[i] = nameVariants[i];
        }

        return IdentityChain({
            sovereignStatus: SOVEREIGN_STATUS,
            birthRecordFull: BIRTH_RECORD_FULL,
            name: BIRTH_NAME,
            nameCaps: PASSPORT_RF_FULL_NAME,
            nameLatin: MRZ_SURNAME,
            nameVariants: variants,
            birthCertSeries: CERTIFICATE_SERIES,
            birthCertNumber: CERTIFICATE_NUMBER,
            birthCertVariants: CERTIFICATE_VARIANTS,
            birthCertType: BIRTH_CERT_TYPE,
            birthCertOid: BIRTH_CERT_OID,
            birthCertId: BIRTH_CERT_ID,
            birthCertStatus: BIRTH_CERT_STATUS,
            passport1Type: PASSPORT_1_TYPE,
            passport1Series: PASSPORT_1_SERIES,
            passport1Number: PASSPORT_1_NUMBER,
            passport1IssueDate: PASSPORT_1_ISSUE_DATE,
            passport1IssuedBy: PASSPORT_1_ISSUED_BY,
            passport1Status: PASSPORT_1_STATUS,
            passport2Series: PASSPORT_2_SERIES,
            passport2Number: PASSPORT_2_NUMBER,
            passport2Variants: PASSPORT_2_VARIANTS,
            passport2Type: PASSPORT_2_TYPE,
            passport2IssueDate: PASSPORT_2_ISSUE_DATE,
            passport2IssuedBy: PASSPORT_2_ISSUED_BY,
            passport2Status: PASSPORT_2_STATUS,
            foreignPassportNumber: FRGN_PASS_NUMBER,
            foreignPassportNumberSolid: FRGN_PASS_NUMBER_SOLID,
            foreignPassportSurname: FRGN_PASS_SURNAME,
            foreignPassportGivenName: FRGN_PASS_GIVEN_NAME,
            passportRfSeries: PASSPORT_RF_SERIES,
            passportRfNumber: PASSPORT_RF_NUMBER,
            passportRfFullNumber: PASSPORT_RF_FULL_NUMBER,
            esiaOid: ESIA_OID,
            docTypeBirth: DOC_TYPE_BIRTH_CERT_USSR,
            docTypePassportHistory: DOC_TYPE_PASSPORT_HISTORY,
            docTypeForeignPassport: DOC_TYPE_FRGN_PASS,
            docTypeRfPassport: DOC_TYPE_RF_PASSPORT,
            identityHash: keccak256(abi.encodePacked(
                BIRTH_NAME,
                PASSPORT_RF_FULL_NAME,
                MRZ_SURNAME,
                CERTIFICATE_SERIES, CERTIFICATE_NUMBER,
                PASSPORT_1_TYPE, PASSPORT_1_SERIES, PASSPORT_1_NUMBER,
                PASSPORT_2_TYPE, PASSPORT_2_SERIES, PASSPORT_2_NUMBER,
                PASSPORT_RF_SERIES, PASSPORT_RF_NUMBER,
                FRGN_PASS_NUMBER,
                ESIA_OID,
                SOVEREIGN_STATUS,
                DOC_TYPE_BIRTH_CERT_USSR,
                DOC_TYPE_PASSPORT_HISTORY,
                DOC_TYPE_FRGN_PASS,
                DOC_TYPE_RF_PASSPORT
            ))
        );
    }

    // ============================================================
    // 17. ИНФОРМАЦИОННЫЕ ФУНКЦИИ
    // ============================================================

    function getSovereignStatus() external view returns (string memory) {
        return SOVEREIGN_STATUS;
    }

    function getBirthInfo() external view returns (
        string memory name,
        string memory birthDateRoman,
        string memory birthDateFull,
        string memory place,
        string memory certSeries,
        string memory certNumber,
        string memory issueDateRoman,
        string memory actRecordFull,
        bytes32 certHash,
        string memory docType,
        // Формат Гостеха
        string memory type,
        string memory oid,
        string memory id,
        string memory status,
        string memory departmentDoc,
        string memory issuedBy,
        string memory issueDate,
        string memory actDate,
        bool actFound
    ) {
        return (
            BIRTH_NAME,
            BIRTH_DATE_ROMAN,
            BIRTH_DATE_FULL,
            BIRTH_PLACE,
            CERTIFICATE_SERIES,
            CERTIFICATE_NUMBER,
            ISSUE_DATE_ROMAN,
            ACT_RECORD_FULL,
            BIRTH_CERT_HASH,
            DOC_TYPE_BIRTH_CERT_USSR,
            BIRTH_CERT_TYPE,
            BIRTH_CERT_OID,
            BIRTH_CERT_ID,
            BIRTH_CERT_STATUS,
            BIRTH_CERT_DEPARTMENT,
            BIRTH_CERT_ISSUED_BY,
            BIRTH_CERT_ISSUE_DATE,
            BIRTH_CERT_ACT_DATE,
            BIRTH_CERT_ACT_FOUND
        );
    }

    function getPassportInfo() external view returns (
        string memory type1, string memory series1, string memory number1, string memory issueDate1, string memory issuedBy1, string memory status1,
        string memory type2, string memory series2, string memory number2, string memory issueDate2, string memory issuedBy2, string memory status2
    ) {
        return (
            PASSPORT_1_TYPE, PASSPORT_1_SERIES, PASSPORT_1_NUMBER, PASSPORT_1_ISSUE_DATE, PASSPORT_1_ISSUED_BY, PASSPORT_1_STATUS,
            PASSPORT_2_TYPE, PASSPORT_2_SERIES, PASSPORT_2_NUMBER, PASSPORT_2_ISSUE_DATE, PASSPORT_2_ISSUED_BY, PASSPORT_2_STATUS
        );
    }

    function getPassportRFCopyInfo() external view returns (
        string memory series,
        string memory number,
        string memory fullNumber,
        string memory fullNumberSolid,
        uint256 issueYear,
        uint256 issueMonth,
        uint256 issueDay,
        string memory issueDate,
        string memory departmentCode,
        string memory issuedBy,
        string memory status,
        string memory relevance,
        string memory departmentDoc,
        string memory fullName,
        string memory birthPlace,
        string memory copyStatus,
        string memory citizenship,
        string memory citizenshipCode,
        string memory docType,
        string memory copyDocType,
        string memory esiaOid
    ) {
        return (
            PASSPORT_RF_SERIES,
            PASSPORT_RF_NUMBER,
            PASSPORT_RF_FULL_NUMBER,
            PASSPORT_RF_FULL_NUMBER_SOLID,
            0, 0, 0,
            PASSPORT_RF_ISSUE_DATE,
            PASSPORT_RF_DEPARTMENT_CODE,
            PASSPORT_RF_ISSUED_BY,
            PASSPORT_RF_STATUS,
            PASSPORT_RF_RELEVANCE,
            PASSPORT_RF_DEPARTMENT_DOC,
            PASSPORT_RF_FULL_NAME,
            PASSPORT_RF_BIRTH_PLACE,
            PASSPORT_RF_COPY_STATUS,
            CITIZENSHIP_RF,
            CITIZENSHIP_RF_CODE,
            DOC_TYPE_RF_PASSPORT,
            DOC_TYPE_RF_PASSPORT_COPY,
            ESIA_OID
        );
    }

    function getForeignPassportInfo() external view returns (
        string memory docType,
        string memory issuingState,
        string memory number,
        string memory numberSolid,
        string memory surname,
        string memory givenName,
        uint256 issueYear,
        uint256 issueMonth,
        uint256 issueDay,
        string memory birthPlace,
        string memory authority,
        string memory mrzFull,
        string memory docTypeGoTech
    ) {
        return (
            FRGN_PASS_TYPE,
            FRGN_PASS_ISSUING_STATE,
            FRGN_PASS_NUMBER,
            FRGN_PASS_NUMBER_SOLID,
            FRGN_PASS_SURNAME,
            FRGN_PASS_GIVEN_NAME,
            FRGN_PASS_ISSUE_YEAR,
            FRGN_PASS_ISSUE_MONTH,
            FRGN_PASS_ISSUE_DAY,
            FRGN_PASS_BIRTH_PLACE,
            FRGN_PASS_AUTHORITY,
            FRGN_PASS_MRZ_FULL,
            DOC_TYPE_FRGN_PASS
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
        string memory authorityCode
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
            REGISTRATION_AUTHORITY_CODE
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
        if (keccak256(typeBytes) == keccak256(bytes("PASSPORT_HISTORY"))) {
            return "История выданных паспортов (СССР, РФ, загран)";
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
        if (keccak256(typeBytes) == keccak256(bytes("FRGN_PASS"))) {
            return "Заграничный паспорт";
        }
        return "Неизвестный тип документа";
    }

    // ============================================================
    // 18. ЗАЩИТА ОТ ПЛАТЕЖЕЙ
    // ============================================================

    receive() external payable {
        revert("ShieldRegistry: payments not accepted");
    }
}
