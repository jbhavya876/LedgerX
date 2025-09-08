import { Clarinet, Tx, Chain, Account, types } from 'clarinet';
import { assertEquals, assert } from 'asserts';

Clarinet.test({
    name: "Property Tokenizer: Allows owner to create a new tokenized property",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        const propertyId = "PROP_NYC_001";
        const propertyAddress = "123 Main St, New York, NY";
        const totalValue = 1_000_000_00; // $1M in cents
        const totalTokens = 100;

        let block = chain.mineBlock([
            Tx.contractCall("property-tokenizer", "create-tokenized-property", [
                types.ascii(propertyId),
                types.ascii(propertyAddress),
                types.uint(totalValue),
                types.uint(totalTokens)
            ], deployer.address)
        ]);

        assertEquals(block.receipts.length, 1);
        assertEquals(block.height, 2);
        block.receipts[0].result.expectOk().expectAscii(propertyId);

        const propertyInfo = chain.callReadOnlyFn("property-tokenizer", "get-property-info", [types.ascii(propertyId)], deployer.address);
        const propertyData = propertyInfo.result.expectSome().expectTuple();

        assertEquals(propertyData['property-address'], types.ascii(propertyAddress));
        assertEquals(propertyData['total-value'], types.uint(totalValue));
        assertEquals(propertyData['price-per-token'], types.uint(totalValue / totalTokens));
    },
});