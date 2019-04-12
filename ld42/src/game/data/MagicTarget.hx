package game.data;

@:enum
abstract MagicTarget(String) from String
{
  var Boss = "boss";
  var Party = "party";
  var PartyAll = "party_all";
  var PartyRandom = "party_random";
}