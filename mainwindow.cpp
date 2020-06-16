#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <stdio.h>
#include <stdlib.h>
#include <winscard.h>
#include <QDebug>
#include <qhexview.h>
#include <document/buffer/qmemorybuffer.h>
#include <QColor>
#include <Qt>

#include <QtWidgets>


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);


    // Load data from In-Memory Buffer...

    QString test= "test123";
    QByteArray test2 = test.toLocal8Bit().data();
    QHexDocument* document = QHexDocument::fromMemory<QMemoryBuffer>(test2);
    // ...from a generic I/O device...
 //   QHexDocument* document = QHexDocument::fromDevice<QMemoryBuffer>(iodevice);
    /* ...or from File */
 //   QHexDocument* document = QHexDocument::fromFile<QMemoryBuffer>("data.bin");

    QHexView* hexview = new QHexView(ui->widget);
    hexview->setDocument(document);                  // Associate QHexEditData with this QHexEdit

    // Document editing
    QByteArray data = document->read(24, 78);        // Read 78 bytes starting to offset 24
    document->insert(4, "Hello QHexEdit");           // Insert a string to offset 4
    document->remove(6, 10);                         // Delete bytes from offset 6 to offset 10
    document->replace(30, "New Data");               // Replace bytes from offset 30 with the string "New Data"

    // Metatadata management
    QHexMetadata* hexmetadata = document->metadata();

    hexmetadata->background(6, 0, 10,Qt::red);      // Highlight background to line 6, from 0 to 10
    hexmetadata->foreground(8, 0, 15, Qt::darkBlue); // Highlight foreground to line 8, from 0 to 15
 //   hexmetadata->comment(16, "I'm a comment!");      // Add a comment to line 16
    hexmetadata->clear();                            // Reset styling



}

MainWindow::~MainWindow()
{
    delete ui;
}




#define CHECK(f, rv) \
    if (SCARD_S_SUCCESS != rv) \
    { \
        fprintf(stderr, f ": %s\n", pcsc_stringify_error(rv)); \
        return -1; \
    }
#define CHECK_RESPONSE(buffer, bufferLength) \
    if(buffer[bufferLength-2] != 0x90 || buffer[bufferLength-1] != 0x00) { \
        fprintf(stderr, "Invalid response!\n"); \
        return -2; \
    }


int PCSC(int argc, char *argv[]) {
    long rv;
    SCARDCONTEXT hContext;
    SCARDHANDLE hCard;
    DWORD dwReaders, dwActiveProtocol, dwRecvLength;
    LPTSTR mszReaders;
    SCARD_IO_REQUEST pioSendPci;
    BYTE pbRecvBuffer[266];
    unsigned int i;

    fprintf(stderr, "Smart Card reader - terciofilho - hashtips.wordpress.com\n");

    BYTE cmdDefineCardType[] = { 0xFF, 0xA4, 0x00, 0x00, 0x01, 0x06 };
    BYTE cmdReadCard[] = { 0xFF, 0xB0, 0x00, 0x20, 0xC0 };

    if(argc != 3)
    {
        fprintf(stderr, "Usage: %s FIRST_ADDRESS READ_LENGTH\nNo parameters provided, default values:\nFIRST_ADDRESS = 0x%X\nREAD_LENGTH = 0x%X\n", argv[0], cmdReadCard[3], cmdReadCard[4]);
    }
    else
    {
        if(strtol(argv[2], NULL, 16) > 256)
        {
            fprintf(stderr, "Invalid READ_LENGTH. Must be < 256.\n");
            return -3;
        }
        cmdReadCard[3] = strtol(argv[1], NULL, 16);
        cmdReadCard[4] = strtol(argv[2], NULL, 16);
        fprintf(stderr, "FIRST_ADDRESS = 0x%02x\nREAD_LENGTH = 0x%02x\n", cmdReadCard[3], cmdReadCard[4]);
    }

    rv = SCardEstablishContext(SCARD_SCOPE_SYSTEM, NULL, NULL, &hContext);
    CHECK("SCardEstablishContext", rv);

    dwReaders = SCARD_AUTOALLOCATE;
    rv = SCardListReaders(hContext, NULL, (LPTSTR)&mszReaders, &dwReaders);
    CHECK("SCardListReaders", rv)
    fprintf(stderr, "Reader name: %s\n", mszReaders);

    rv = SCardConnect(hContext, mszReaders, SCARD_SHARE_SHARED, SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1, &hCard, &dwActiveProtocol);
    CHECK("SCardConnect", rv)

    switch(dwActiveProtocol)
    {
        case SCARD_PROTOCOL_T0:
            pioSendPci = *SCARD_PCI_T0;
            break;

        case SCARD_PROTOCOL_T1:
            pioSendPci = *SCARD_PCI_T1;
            break;
    }
    dwRecvLength = sizeof(pbRecvBuffer);

    rv = SCardTransmit(hCard, &pioSendPci, cmdDefineCardType, sizeof(cmdDefineCardType), NULL, pbRecvBuffer, &dwRecvLength);
    CHECK("SCardTransmit", rv)
    CHECK_RESPONSE(pbRecvBuffer, dwRecvLength);

    dwRecvLength = sizeof(pbRecvBuffer);
    rv = SCardTransmit(hCard, &pioSendPci, cmdReadCard, sizeof(cmdReadCard), NULL, pbRecvBuffer, &dwRecvLength);
    CHECK("SCardTransmit", rv)
    CHECK_RESPONSE(pbRecvBuffer, dwRecvLength);

    for(i=0; i<dwRecvLength-2; i++)
        printf("%c", pbRecvBuffer[i]);

    rv = SCardDisconnect(hCard, SCARD_LEAVE_CARD);
    CHECK("SCardDisconnect", rv);

    rv = SCardFreeMemory(hContext, mszReaders);
    CHECK("SCardFreeMemory", rv);

    rv = SCardReleaseContext(hContext);
    CHECK("SCardReleaseContext", rv);
}

int PCSC_wrapper(char* csv)
{
std::vector<char*> parts;
char* part = strtok(csv, ",");
while (part) {
    parts.push_back(part);
    part = strtok(nullptr, ",");
}
return PCSC(parts.size(), parts.data());
}


void MainWindow::on_pushButton_clicked()
{
//https://hashtips.wordpress.com/author/terciofilho/
  //  Select Card Type, in this case SLE4432 or SLE4442 or SLE5532 or SLE5542.
   //     Command: “FF A4 00 00 01 06”, this command powers down and powers up the selected card and performs a card reset.
   // Read card content
  //      Command: “FF B0 00 XX YY”, this command reads the card memory at address XX, YY bytes long.

  //  # Will read 128 bytes starting at the 32th byte.
  //  $ ./smartCardRead 20 80
  //  # Will read 16 bytes starting at the first byte.
  //  $ ./smartCardRead 00 10
 //   By default, it will read from the first address, 256 bytes.

    QString fileslist;
     fileslist.append("blank,");
  //   fileslist.append("-f,");
     QByteArray array = fileslist.toLocal8Bit();
     char* buffer = array.data();

     if(PCSC_wrapper(buffer)) {
         qDebug() << "successful";
     }else{
                        qDebug() << "returned false";
     }

}
