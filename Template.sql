CREATE TABLE DeliveryRequest (
  requestID INT
);

CREATE TABLE AcceptableRequest (

);

CREATE TABLE UnacceptableRequest (

);

CREATE TABLE AcceptedRequest (
  creditCard       INT,
  paymentTimestamp INT
);

CREATE TABLE WithdrawnRequest (

);

CREATE TABLE NormalDeliveryRequest (

);

CREATE TABLE ReturnDeliveryRequest (

);

CREATE TABLE Package (
  packageID  INT,
  weight     INT,
  dimensions INT
);

CREATE TABLE Employee (
  employeeID INT
);

CREATE TABLE Customer (
  customerID INT
);

CREATE TABLE Leg (

);

CREATE TABLE FirstLeg (
  weight     INT,
  dimensions INT
);

CREATE TABLE IntermediateLeg (

);

CREATE TABLE FinalLeg (
  destAddress INT
);

CREATE TABLE Facility (

);

CREATE TABLE Delivers (
  srcAddress  INT,
  destAddress INT
);

CREATE TABLE Precedes (

);

CREATE TABLE Has (

);

CREATE TABLE Pickup (

);

CREATE TABLE HandlesReq (

);

CREATE TABLE HandlesLeg (

);

CREATE TABLE Makes (

);

CREATE TABLE Consists (

);

CREATE TABLE Records (

);

