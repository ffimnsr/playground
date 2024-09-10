/**
 * Program IDL in camelCase format in order to be used in JS/TS.
 *
 * Note that this is only a type helper and is not the actual IDL. The original
 * IDL can be found at `target/idl/todo_sol.json`.
 */
export type TodoSol = {
  "address": "3ibA1xfXF5otPPpL94eoqrSDwVaYrQRz36zAQqtbAzL5",
  "metadata": {
    "name": "todoSol",
    "version": "0.1.0",
    "spec": "0.1.0",
    "description": "Created with Anchor"
  },
  "instructions": [
    {
      "name": "addTodo",
      "discriminator": [
        188,
        16,
        45,
        145,
        4,
        5,
        188,
        75
      ],
      "accounts": [
        {
          "name": "userProfile",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  85,
                  83,
                  69,
                  82,
                  95,
                  83,
                  84,
                  65,
                  84,
                  69
                ]
              },
              {
                "kind": "account",
                "path": "authority"
              }
            ]
          }
        },
        {
          "name": "todoAccount",
          "writable": true
        },
        {
          "name": "authority",
          "writable": true,
          "signer": true
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "content",
          "type": "string"
        }
      ]
    },
    {
      "name": "initialize",
      "discriminator": [
        175,
        175,
        109,
        31,
        13,
        152,
        155,
        237
      ],
      "accounts": [
        {
          "name": "userProfile",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  85,
                  83,
                  69,
                  82,
                  95,
                  83,
                  84,
                  65,
                  84,
                  69
                ]
              },
              {
                "kind": "account",
                "path": "authority"
              }
            ]
          }
        },
        {
          "name": "authority",
          "writable": true,
          "signer": true
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": []
    },
    {
      "name": "markTodo",
      "discriminator": [
        70,
        24,
        206,
        243,
        92,
        29,
        249,
        110
      ],
      "accounts": [
        {
          "name": "userProfile",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  85,
                  83,
                  69,
                  82,
                  95,
                  83,
                  84,
                  65,
                  84,
                  69
                ]
              },
              {
                "kind": "account",
                "path": "authority"
              }
            ]
          }
        },
        {
          "name": "todoAccount",
          "writable": true
        },
        {
          "name": "authority",
          "writable": true,
          "signer": true
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "todoIdx",
          "type": "u8"
        }
      ]
    },
    {
      "name": "removeTodo",
      "discriminator": [
        28,
        167,
        91,
        69,
        25,
        225,
        253,
        117
      ],
      "accounts": [
        {
          "name": "userProfile",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  85,
                  83,
                  69,
                  82,
                  95,
                  83,
                  84,
                  65,
                  84,
                  69
                ]
              },
              {
                "kind": "account",
                "path": "authority"
              }
            ]
          }
        },
        {
          "name": "todoAccount",
          "writable": true
        },
        {
          "name": "authority",
          "writable": true,
          "signer": true
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "todoIdx",
          "type": "u8"
        }
      ]
    },
    {
      "name": "unmarkTodo",
      "discriminator": [
        195,
        238,
        237,
        86,
        180,
        108,
        141,
        51
      ],
      "accounts": [
        {
          "name": "userProfile",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  85,
                  83,
                  69,
                  82,
                  95,
                  83,
                  84,
                  65,
                  84,
                  69
                ]
              },
              {
                "kind": "account",
                "path": "authority"
              }
            ]
          }
        },
        {
          "name": "todoAccount",
          "writable": true
        },
        {
          "name": "authority",
          "writable": true,
          "signer": true
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "todoIdx",
          "type": "u8"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "todoAccount",
      "discriminator": [
        31,
        86,
        84,
        40,
        187,
        31,
        251,
        132
      ]
    },
    {
      "name": "userProfile",
      "discriminator": [
        32,
        37,
        119,
        205,
        179,
        180,
        13,
        194
      ]
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "unauthorized",
      "msg": "You are not authorized to perform this action."
    },
    {
      "code": 6001,
      "name": "notAllowed",
      "msg": "The operation is not allowed."
    },
    {
      "code": 6002,
      "name": "mathOverflow",
      "msg": "Math overflow."
    },
    {
      "code": 6003,
      "name": "contentTooLong",
      "msg": "Content is too long."
    },
    {
      "code": 6004,
      "name": "alreadyMarked",
      "msg": "The todo is already marked."
    },
    {
      "code": 6005,
      "name": "alreadyUnmarked",
      "msg": "The todo is already unmarked."
    }
  ],
  "types": [
    {
      "name": "todoAccount",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "author",
            "type": "pubkey"
          },
          {
            "name": "bump",
            "type": "u8"
          },
          {
            "name": "idx",
            "type": "u8"
          },
          {
            "name": "content",
            "type": "string"
          },
          {
            "name": "marked",
            "type": "bool"
          }
        ]
      }
    },
    {
      "name": "userProfile",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "bump",
            "type": "u8"
          },
          {
            "name": "lastTodo",
            "type": "u8"
          },
          {
            "name": "todoCount",
            "type": "u8"
          }
        ]
      }
    }
  ],
  "constants": [
    {
      "name": "todoTag",
      "type": "bytes",
      "value": "[84, 79, 68, 79, 95, 83, 84, 65, 84, 69]"
    },
    {
      "name": "userTag",
      "type": "bytes",
      "value": "[85, 83, 69, 82, 95, 83, 84, 65, 84, 69]"
    }
  ]
};
