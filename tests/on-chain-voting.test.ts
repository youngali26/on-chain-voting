declare const describe: (name: string, fn: () => void) => void;
declare const it: (name: string, fn: () => void) => void;
declare const expect: any;

declare const simnet: {
  getAccounts: () => Map<string, string>;
  callPublicFn: (contract: string, method: string, args: any[], sender: string) => { result: any };
  callReadOnlyFn: (contract: string, method: string, args: any[], sender: string) => { result: any };
};

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const address3 = accounts.get("wallet_3")!;

describe("on-chain-voting tests", () => {
  it("allows creating a new proposal", () => {
    const { result } = simnet.callPublicFn(
      "on-chain-voting",
      "create-proposal",
      ["test-proposal", "test description", 100n],
      address1
    );
    expect(result).toBeOk(0n);
  });

  it("allows voting on a proposal", () => {
    // Create proposal first
    simnet.callPublicFn(
      "on-chain-voting",
      "create-proposal",
      ["test-proposal", "test description", 100n],
      address1
    );

    const { result } = simnet.callPublicFn(
      "on-chain-voting",
      "vote",
      [0n, true],
      address2
    );
    expect(result).toBeOk(true);
  });

  it("prevents double voting", () => {
    // Create proposal
    simnet.callPublicFn(
      "on-chain-voting",
      "create-proposal",
      ["test-proposal", "test description", 100n],
      address1
    );

    // First vote should succeed
    simnet.callPublicFn(
      "on-chain-voting",
      "vote",
      [0n, true],
      address2
    );

    // Second vote should fail
    const { result } = simnet.callPublicFn(
      "on-chain-voting",
      "vote",
      [0n, true],
      address2
    );
    expect(result).toBeErr(2n);
  });

  it("allows checking voting results", () => {
    // Create proposal
    simnet.callPublicFn(
      "on-chain-voting",
      "create-proposal",
      ["test-proposal", "test description", 100n],
      address1
    );

    // Cast some votes
    simnet.callPublicFn("on-chain-voting", "vote", [0n, true], address2);
    simnet.callPublicFn("on-chain-voting", "vote", [0n, false], address3);

    const { result } = simnet.callReadOnlyFn(
      "on-chain-voting",
      "get-result",
      [0n],
      address1
    );

    const unwrappedResult = result.expectOk().expectTuple();
    expect(unwrappedResult["for-votes"]).toBeUint(1n);
    expect(unwrappedResult["against-votes"]).toBeUint(1n);
  });
});
