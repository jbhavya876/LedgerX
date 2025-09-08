// declarations.d.ts
declare module "clarinet" {
    // Very small friendly typings for typical Clarinet test usage
    export interface Account {
        address: string;
        publicKey?: string;
        privateKey?: string;
    }

    export interface ReceiptResult {
        expectOk: () => any;
        expectErr: (v?: any) => any;
        expectAscii?: (s: string) => any;
    }

    export interface Receipt {
        result: ReceiptResult;
    }

    export interface Block {
        receipts: Receipt[];
        height: number;
    }

    export interface Chain {
        mineBlock(txs: any[]): Block;
    }

    export const Tx: {
        contractCall: (
            contract: string,
            func: string,
            args: any[],
            sender: string
        ) => any;
    };

    export const types: {
        ascii: (s: string) => any;
        utf8: (s: string) => any;
        some: (v: any) => any;
        none: () => any;
        list: (items: any[]) => any;
        principal: (addr: string) => any;
        uint: (n: number) => any;
    };

    export const Clarinet: {
        test: (opts: {
            name: string;
            fn: (chain: Chain, accounts: Map<string, Account>) => Promise<void> | void;
        }) => void;
    };
    export type AccountMap = Map<string, Account>;
}

declare module "asserts" {
    export function assertEquals(actual: any, expected: any, msg?: string): void;
    export function assertTrue(value: any, msg?: string): void;
    export function assertFalse(value: any, msg?: string): void;
} 