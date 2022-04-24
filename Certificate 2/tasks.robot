*** Settings ***
Documentation     Template robot main suite.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.Tables
Library           RPA.HTTP
Library           RPA.Desktop.Windows
Library           RPA.PDF
Library           RPA.Archive

*** Variables ***
${GLOBAL_RETRY_AMOUNT}=    3x
${GLOBAL_RETRY_INTERVAL}=    0.5s

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download the orders file
    Read order file as table
    #Retry order
    #Get order number and store as PDF
    #Take only Screenshot
    Save ZIP

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    OK

Download the orders file
    Download    https://robotsparebinindustries.com/orders.csv

Fill and submit the from for one order
    [Arguments]    ${orders}
    ${legs}    Convert To String    1649940399165
    Select From List By Index    head    ${orders}[Head]
    Click Element    id-body-${orders}[Body]
    Input Text    xpath=/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${orders}[Legs]
    Input Text    address    ${orders}[Address]
    Click Button    preview

Read order file as table
    ${orders}=    Read table from CSV    orders.csv
    Log    ${orders}
    FOR    ${orders}    IN    @{orders}
        Fill and submit the from for one order    ${orders}
        Retry order
        Click Button    order-another
        Click Button    OK
    END

Submit order
    Click Button    order
    Wait Until Element Is Visible    id:receipt
    Get order number and store as PDF

Retry order
    Wait Until Keyword Succeeds    ${GLOBAL_RETRY_AMOUNT}    ${GLOBAL_RETRY_INTERVAL}    Submit order

Store order as PDF
    [Arguments]    ${order_number}
    ${order_receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${order_receipt_html}    ${OUTPUT_DIR}${/}/raw_data/${order_number}_data.pdf
    #Take only Screenshot    ${order_number}
    ${screenshot}=    RPA.Browser.Selenium.Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}/raw_data/${order_number}.png
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}/raw_data/${order_number}.png
    ...    ${OUTPUT_DIR}${/}/raw_data/${order_number}_data.pdf
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}/receipts/${order_number}.pdf

Get order number and store as PDF
    ${order_number}=    RPA.Browser.Selenium.Get Text    xpath= /html/body/div/div/div[1]/div/div[1]/div/div/p[1]
    Store order as PDF    ${order_number}

Take only Screenshot
    [Arguments]    ${order_number}
    ${screenshot}=    RPA.Browser.Selenium.Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}/receipts/${order_number}.png
    Embed Screenshot in PDF    ${screenshot}    ${order_number}

Embed Screenshot in PDF
    [Arguments]    ${screen}    ${order_number}
    ${order_number}
    ${screen}
    Add Files To Pdf    ${screen}    ${OUTPUT_DIR}${/}/receipts/${order_number}.pdf

Save ZIP
    Archive Folder With Zip    ${OUTPUT_DIR}${/}/receipts    receipts_zip
