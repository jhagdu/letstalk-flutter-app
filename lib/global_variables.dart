/*-----------------------------------------------
This Module is only for Global Variables
Contains Global Variables which are used Mostly 
-------------------------------------------------*/

//Importing Required Modules
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

//Device Configurations
var deviceHeight;
var deviceWidth;

//Firestore Instance
var letsChatFS = FirebaseFirestore.instance;

//Storage Instance
var letsChatStorage = FirebaseStorage.instance;

//User Details
var email;
var username;
