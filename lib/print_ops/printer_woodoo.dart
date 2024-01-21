import 'package:printing/printing.dart';

// class PrinterWoodoo extends Printer {
//   PrinterWoodoo() : super('WooDoo');
//
//   @override
//   Future<bool> connect() async {
//     return true;
//   }
//
//   @override
//   Future<bool> disconnect() async {
//     return true;
//   }
//
//   @override
//   Future<bool> printTicket(Ticket ticket) async {
//     return true;
//   }
//
//   @override
//   Future<bool> isConnected() async {
//     return true;
//   }
// }
class PrinterWoodoo{

  printAll(){
    print('printAll');
  }
  printSelected(){
    print('printSelected');
  }
appendPrintQueue() {
  print('appendPrintQueue');
}
appendPrintOne(){

}
}