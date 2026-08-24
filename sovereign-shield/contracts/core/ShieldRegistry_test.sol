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
        string certificateSeries;
        string certificateNumber;
        string[] certificateSeriesVariants;
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

    // ---- Единственный экземпляр структуры с вашими данными ----
    BirthCertificateUSSR public birthCertificate = BirthCertificateUSSR({
        docType: "OLD_BRTH_CERT",
        oid: "2080144827",
        id: "1394776",
        relevance: "actual",
        status: "unverified",
        departmentDoc: "Орган записи актов гражданского состояния",
        firstName: "Евгений",
        lastName: "Масленников",
        middleName: "Владиславович",
        fullName: "Масленников Евгений Владиславович",
        fullNameCaps: "МАСЛЕННИКОВ ЕВГЕНИЙ ВЛАДИСЛАВОВИЧ",
        birthDate: Date({
            day: 12,
            month: 6,
            monthRoman: "VI",
            year: 1968,
            fullText: "12 VI 1968"
        }),
        birthDateFullText: "Двенадцатого июня тысяча девятьсот шестьдесят восьмого года",
        birthPlace: "город Павлодар, Казахская Советская Социалистическая Республика в составе Союза Советских Социалистических Республик (С.С.С.Р.)",
        certificateSeries: "I-КА",
        certificateNumber: "020727",
        certificateSeriesVariants: new string[](0),
        issueDate: Date({
            day: 10,
            month: 7,
            monthRoman: "VII",
            year: 1968,
            fullText: "10 VII 1968"
        }),
        issuedBy: "СССР",
        actRecordNumber: "1903",
        actRecordDate: Date({
            day: 10,
            month: 7,
            monthRoman: "VII",
            year: 1968,
            fullText: "10 VII 1968"
        }),
        actRecordFullText: "о чем в государственной книге записей актов гражданского состояния 1968 года VII месяца 10 числа произведена соответствующая запись акта о рождении за № 1903",
        actRecordFound: true,
        hash: 0x1F8DE3FDC2C61647E697243FC05CDB83C12CCC75987658D584690928427CFA34
    });

    // ---- Заполнение массива вариантов серии ----
    function initializeCertificateVariants() internal {
        string[7] memory variants = [
            "I-КА 020727",
            "IКА 020727",
            "IКА020727",
            "ИКА020727",
            "ИКА 020727",
            "IKA020727",
            "IKA 020727"
        ];
        
        // В конструкторе или отдельной функции добавляем варианты в массив
        // Это можно сделать только один раз при деплое
        // Solidity не позволяет инициализировать динамические массивы в структуре напрямую
    }
