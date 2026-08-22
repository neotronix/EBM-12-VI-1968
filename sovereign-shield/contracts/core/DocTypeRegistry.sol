// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DocTypeRegistry
 * @author Суверен Масленников Е.В. / ATLAS-3I
 * @notice Реестр для хранения параметров типов документов (мнемоник Гостеха).
 * @dev Позволяет гибко добавлять, обновлять и удалять информацию о типах документов.
 */
contract DocTypeRegistry {
    // Структура для хранения параметров типа документа
    struct DocTypeInfo {
        bool isForbidden;       // Запрещен ли для долговых обязательств
        string scope;           // Требуемая область доступа
        uint256 stalePeriod;    // Срок устаревания в часах
    }

    // Адрес Суверена (устанавливается при деплое)
    address public immutable SOVEREIGN;

    // Маппинг: мнемоника документа -> его параметры
    mapping(bytes32 => DocTypeInfo) public docTypes;

    // События
    event DocTypeAdded(string docType, bool isForbidden, string scope, uint256 stalePeriod);
    event DocTypeUpdated(string docType, bool isForbidden, string scope, uint256 stalePeriod);
    event DocTypeRemoved(string docType);

    constructor() {
        SOVEREIGN = msg.sender;
    }

    /**
     * @dev Добавляет или обновляет параметры типа документа.
     */
    function setDocType(
        string memory docType,
        bool isForbidden,
        string memory scope,
        uint256 stalePeriod
    ) external {
        require(msg.sender == SOVEREIGN, "DocTypeRegistry: only Sovereign can manage");
        bytes32 key = keccak256(bytes(docType));
        docTypes[key] = DocTypeInfo({
            isForbidden: isForbidden,
            scope: scope,
            stalePeriod: stalePeriod
        });
        emit DocTypeAdded(docType, isForbidden, scope, stalePeriod);
    }

    /**
     * @dev Удаляет тип документа из реестра.
     */
    function removeDocType(string memory docType) external {
        require(msg.sender == SOVEREIGN, "DocTypeRegistry: only Sovereign can manage");
        bytes32 key = keccak256(bytes(docType));
        delete docTypes[key];
        emit DocTypeRemoved(docType);
    }

    /**
     * @dev Возвращает параметры типа документа.
     */
    function getDocTypeInfo(string memory docType) external view returns (
        bool isForbidden,
        string memory scope,
        uint256 stalePeriod
    ) {
        DocTypeInfo memory info = docTypes[keccak256(bytes(docType))];
        return (info.isForbidden, info.scope, info.stalePeriod);
    }

    /**
     * @dev Проверяет, запрещен ли тип документа.
     */
    function isDocTypeForbidden(string memory docType) external view returns (bool) {
        return docTypes[keccak256(bytes(docType))].isForbidden;
    }
}
