// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerinax/googleapis.sheets as sheets;
import ballerina/log;

configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

sheets:ConnectionConfig spreadsheetConfig = {
    auth: {
        clientId: clientId,
        clientSecret: clientSecret,
        refreshUrl: sheets:REFRESH_URL,
        refreshToken: refreshToken
    }
};

sheets:Client spreadsheetClient = check new (spreadsheetConfig);

public function main() returns error? {
    string spreadsheetId = "";
    string sheetName = "";

    // Create Spreadsheet with given name
    sheets:Spreadsheet|error response = spreadsheetClient->createSpreadsheet("NewSpreadsheet");
    if (response is sheets:Spreadsheet) {
        log:printInfo("Spreadsheet Details: " + response.toString());
        spreadsheetId = response.spreadsheetId;
    } else {
        log:printError("Error: " + response.toString());
    }

    // Add a New Worksheet with given name to the Spreadsheet with the given Spreadsheet ID 
    sheets:Sheet|error sheet = spreadsheetClient->addSheet(spreadsheetId, "NewWorksheet");
    if (sheet is sheets:Sheet) {
        log:printInfo("Sheet Details: " + sheet.toString());
        sheetName = sheet.properties.title;
    } else {
        log:printError("Error: " + sheet.toString());
    }

    string a1Notation = "B2";

    // Sets the value of the given cell of the Sheet
    error? spreadsheetRes = spreadsheetClient->setCell(spreadsheetId, sheetName, a1Notation, "ModifiedValue");
    if (spreadsheetRes is ()) {
        // Gets the value of the given cell of the Sheet
        sheets:Cell|error getValuesResult = spreadsheetClient->getCell(spreadsheetId, sheetName, a1Notation);
        if (getValuesResult is sheets:Cell) {
            log:printInfo("Cell Details: " + getValuesResult.toString());
        } else {
            log:printError("Error: " + getValuesResult.toString());
        }

        // Clears the given cell of contents, formats, and data validation rules.
        error? clear = spreadsheetClient->clearCell(spreadsheetId, sheetName, a1Notation);
        if (clear is ()) {
            sheets:Cell|error openRes = spreadsheetClient->getCell(spreadsheetId, sheetName, a1Notation);
            if (openRes is sheets:Cell) {
                log:printInfo("Cell Details: " + openRes.toString());
            } else {
                log:printError("Error: " + openRes.toString());
            }
        } else {
            log:printError("Error: " + clear.toString());
        }
    } else {
        log:printError("Error: " + spreadsheetRes.toString());
    }
}