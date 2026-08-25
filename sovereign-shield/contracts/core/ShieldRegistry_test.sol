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
    // 0. СТРУКТУРЫ ДАННЫХ
    // ============================================================

    // Структура для даты с поддержкой нескольких форматов
    struct Date {
        uint8 day;
        uint8 month;
        string monthRoman;
        uint16 year;
        string fullText;
    }

    // Структура для свидетельства о рождении (СССР)
    struct BirthCertificateUSSR {
        string docType;
        string oid;
        string id;
        string relevance;
        string status;
        string departmentDoc;
        string firstName;
        string lastName;
        string middleName;
        string fullName;
        string fullNameCaps;
        Date birthDate;
        string birthDateFullText;
        string birthPlace;
        string BirthCertificateSeries;
        string BirthCertificateSeriesRoman;
        string BirthCertificateNumber;
        string BirthCertificateNumberRoman;
        string[] BirthCertificateSeriesVariants;
        string[] BirthCertificateNumberVariants;
        Date issueDate;
        string issuedBy;
        string actRecordNumber;
        Date actRecordDate;
        string actRecordFullText;
        bool actRecordFound;
        bytes32 hash;
    }

    // ============================================================
    // 1. ДАННЫЕ СВИДЕТЕЛЬСТВА О РОЖДЕНИИ (I-КА № 020727)
    // ============================================================

    BirthCertificateUSSR public birthCertificate;

    // ---- Конструктор ----
    constructor() {
        SOVEREIGN = msg.sender;
        DEPLOY_BLOCK = block.number;
        DEPLOY_TIME = block.timestamp;

        // Инициализируем свидетельство о рождении
        _initBirthCertificate();

        emit ShieldActivated(
            SOVEREIGN,
            birthCertificate.hash,
            DEPLOY_BLOCK,
            DEPLOY_TIME
        );
    }

    // ---- Функция для получения массива вариантов серии ----
    function _getBirthCertificateSeriesVariants() private pure returns (string[] memory) {
        string[7] memory variants = [
            "I-КА",
            "IКА",
            "IКА",
            "ИКА",
            "ИКА",
            "IKA",
            "IKA"
        ];

        string[] memory result = new string[](7);
        for (uint i = 0; i < 7; i++) {
            result[i] = variants[i];
        }
        return result;
    }

    // ---- Инициализация структуры свидетельства ----
    function _initBirthCertificate() private {
        birthCertificate = BirthCertificateUSSR({
            docType: "OLD_BRTH_CERT",
            oid: "",
            id: "",
            relevance: "actual",
            status: "verified",
            departmentDoc: "бюро записей актов гражданского состояния, 
город Павлодар, Казахская Советская Социалистическая Республика в составе Сoюзa Cовeтcких Социaлиcтичeских Реcпyблик (С.С.С.Р.)",
            firstName: "Евгений",
            lastName: "Масленников",
            middleName: "Владиславович",
            fullName: "Масленников Евгений Владиславович",
            birthDate: Date({
                day: 12,
                month: 6,
                monthRoman: "VI",
                year: 1968,
                fullText: "12 VI 1968"
            }),
            birthDateFullText: "родился Двенадцатого июня тысяча девятьсот шестьдесят восьмого года",
            birthPlace: "город Павлодар, Казахская Советская Социалистическая Республика в составе Союза Советских Социалистических Республик (С.С.С.Р.)",
            BirthCertificateSeries: "I-КА",
            BirthCertificateSeriesRoman: "I-КА",
            BirthCertificateNumber: "020727",
            BirthCertificateSeriesVariants: _getBirthCertificateSeriesVariants(),
            BirthCertificateNumberVariants: new string[](0),
            BirthCertificateIssueDate: Date({
                day: 10,
                month: 7,
                monthRoman: "VII",
                year: 1968,
                fullText: "10 VII 1968"
            }),
            issuedBy: "СССР",
            BirthActRecordNumber: "1903",
            BirthActRecordDate: Date({
                day: 10,
                month: 7,
                monthRoman: "VII",
                year: 1968,
                fullText: "10 VII 1968"
            }),
            BirthActRecordFullText: "о чем в государственной книге записей актов гражданского состояния 1968 года VII месяца 10 числа 
произведена соответствующая запись акта о рождении за № 1903",
            BirthActRecordFound: true,
            hash: 0x1F8DE3FDC2C61647E697243FC05CDB83C12CCC75987658D584690928427CFA34
        });
    }

    // ============================================================
    // 2. ДАННЫЕ ПАСПОРТОВ ГРАЖДАНИНА СССР
    //    Мнемоника Гостеха: PASSPORT_HISTORY
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

    string[] public constant PASSPORT_2_VARIANTS = [
        "IV-ДА",
        "IVДА",
        "IVDA",
        "4ДА606724",
        "4DA606724",
        "4ДА",
        "4DA"
    ];

    // ---- Данные для интеграции с Гостехом (формат API) ----
    string public constant PASSPORT_1_TYPE = "ussr_passport";
    string public constant PASSPORT_1_ISSUE_DATE = "03.08.1984";
    string public constant PASSPORT_1_ISSUED_BY = "Главное управление по вопросам миграции МВД России";
    string public constant PASSPORT_1_STATUS = "noInformation";

    string public constant PASSPORT_2_TYPE = "ussr_passport";
    string public constant PASSPORT_2_ISSUE_DATE = "31.05.1995";
    string public constant PASSPORT_2_ISSUED_BY = "Главное управление по вопросам миграции МВД России";
    string public constant PASSPORT_2_STATUS = "noInformation";

    string public constant DOC_TYPE_PASSPORT_HISTORY = "PASSPORT_HISTORY";
    string public constant CITIZENSHIP = "Союз Советских Социалистических Республик (СССР)";
    string public constant CITIZENSHIP_CODE = "810";

    // ============================================================
    // 3. КОПИЯ ПАСПОРТА ГРАЖДАНИНА РОССИЙСКОЙ ФЕДЕРАЦИИ
    // ============================================================

    string public constant PASSPORT_RF_SERIES = "4613";
    string public constant PASSPORT_RF_NUMBER = "195533";
    string public constant PASSPORT_RF_FULL_NUMBER = "4613 195533";
    string public constant PASSPORT_RF_FULL_NUMBER_SOLID = "4613195533";

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

    string public constant DOC_TYPE_FRGN_PASS = "FRGN_PASS";

    // ============================================================
    // 6. ДАННЫЕ АЛЛОДА (СИСТЕМА КООРДИНАТ 1942 Г.)
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

    // ============================================================
    // 14. ИНФОРМАЦИОННЫЕ ФУНКЦИИ
    // ============================================================

    function getBirthInfo() external view returns (
        string memory docType,
        string memory oid,
        string memory id,
        string memory relevance,
        string memory status,
        string memory departmentDoc,
        string memory firstName,
        string memory lastName,
        string memory middleName,
        string memory fullName,
        string memory fullNameCaps,
        uint8 birthDay,
        uint8 birthMonth,
        string memory birthMonthRoman,
        uint16 birthYear,
        string memory birthDateFullText,
        string memory birthPlace,
        string memory certSeries,
        string memory certSeriesRoman,
        string memory certNumber,
        string memory certNumberRoman,
        string[] memory certSeriesVariants,
        uint8 issueDay,
        uint8 issueMonth,
        string memory issueMonthRoman,
        uint16 issueYear,
        string memory issuedBy,
        string memory actNumber,
        uint8 actDay,
        uint8 actMonth,
        string memory actMonthRoman,
        uint16 actYear,
        string memory actFullText,
        bool actFound,
        bytes32 certHash
    ) {
        Date memory birth = birthCertificate.birthDate;
        Date memory issue = birthCertificate.issueDate;
        Date memory act = birthCertificate.actRecordDate;

        return (
            birthCertificate.docType,
            birthCertificate.oid,
            birthCertificate.id,
            birthCertificate.relevance,
            birthCertificate.status,
            birthCertificate.departmentDoc,
            birthCertificate.firstName,
            birthCertificate.lastName,
            birthCertificate.middleName,
            birthCertificate.fullName,
            birthCertificate.fullNameCaps,
            birth.day, birth.month, birth.monthRoman, birth.year,
            birthCertificate.birthDateFullText,
            birthCertificate.birthPlace,
            birthCertificate.certificateSeries,
            birthCertificate.certificateSeriesRoman,
            birthCertificate.certificateNumber,
            birthCertificate.certificateNumberRoman,
            birthCertificate.certificateSeriesVariants,
            issue.day, issue.month, issue.monthRoman, issue.year,
            birthCertificate.issuedBy,
            birthCertificate.actRecordNumber,
            act.day, act.month, act.monthRoman, act.year,
            birthCertificate.actRecordFullText,
            birthCertificate.actRecordFound,
            birthCertificate.hash
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
    // 15. ЗАЩИТА ОТ ПЛАТЕЖЕЙ
    // ============================================================

    receive() external payable {
        revert("ShieldRegistry: payments not accepted");
    }
}
