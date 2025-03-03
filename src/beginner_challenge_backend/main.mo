import Result "mo:base/Result";
import Text "mo:base/Text";
import Debug "mo:base/Debug";
import Types "types";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Cycles "mo:base/ExperimentalCycles";
import map "mo:base/Map";
import { phash; nhash } "mo:base/Map";
import Nat "mo:base/Nat";
import Vector "mo:vector";

actor {
    stable var autoIndex = 0;
    let usedIdMap = Map.new<Principal, Nat>();
    let userProfileMap = Map.new<Nat, Text>();
    let userResultsMap  = Map.new<Nat, Vector.Vector<Text>>();



    public query ({ caller }) func getUserProfile() : async Result.Result<{ id : Nat; name : Text }, Text> {
        return #ok({ id = 123; name = "test" });
    };




   public shared ({ caller }) func setUserProfile(name : Text) : async Result.Result<{ id : Nat; name : Text }, Text> {
    // check if user already exists
    switch (Map.get(userIdMap, phash, caller)) {
        case (?x) {
            // set user id
            Map.set(userIdMap, phash, caller, autoIndex);
            // increment for next user
            autoIndex += 1;
        }
        case (_) {};
    }
    // set profile name
    let foundId = switch (Map.get(userIdMap, phash, caller)) {
        case (?found) found;
        case (_) { return #err("User not found") };
    };
    Map.set(userProfileMap, nhash, foundId, name);
    return #ok({ id = foundId; name = name });
}


  public shared ({ caller }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
    // check if user exists
    let userId = switch (Map.get(userIdMap, phash, caller)) {
        case (?found) found;
        case (_) return #err("User not found");
    };
    let results = switch (Map.get(userResultsMap, nhash, userId)) {
        case (?found) found;
        case (_) Vector.new<Text>();
    };
    Vector.add(results, result);
    Map.set(userResultsMap, nhash, userId, results);
    return #ok({ id = userId; results = Vector.toArray(results) });
}


    public query ({ caller }) func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        return #ok({ id = 123; results = ["fake result"] });
    };
};
