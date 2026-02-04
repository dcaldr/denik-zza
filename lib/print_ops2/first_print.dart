/// attach to print_center.dart, use similar ui to steps flow in print sector
/// flow:1) screen explain what append print is (useful) what it needs from user to do - and that this will contain some text and getting use to
///  2) ask user to load 2 sheets of paper into the printer + then to see what paper is on top when both printed
///  3) Print the two papers with bottom page number; header should be simple this is page N , two mock records marking page number and print pass
///  4) ask user to confirm which page is on top (1 or 2) and then explain why is it needed to know that (to determine if we can reuse the last page or need to insert a new one)
///  5) make new db field(s) for that so we remember the user choice for future prints (and also to use it in the append algorithm)
///  6) after confirms ask user to put the same papers in same order (top one on top ) SIgnify that no rotating and no flipping - just simple put in
///  7) append print two new records to each page (again with page number and pass numeber
///  8) ask user to confirm corectness with (two step? popup) first asking for any unforseen error+ explaining confirm widnow that will be later used , then the confirm widow we use in project,
///