Parentheses and brackets are used to modify the model's attention or emphasis on specific words in prompt. Parenthesis `()` increase attention, while brackets `[]` decrease attention. The level of attention can be further adjusted using numerical weights or by nesting the parenthesis or brackets.

Example prompt:

```text
I want to see a (beautiful) [scary] forest.
```

In this example, the model will give more attention to the word "beautiful" and less attention to the word "scary".

The numerical weights only works with parenthesis, not with brackets.

Example prompt:

```
I want to see a (beautiful:1.5) (scary:0.5) [haunted:0.25] forest.
```

In this example above, the model will give 50% more attention to the word "beautiful" and 50% less attention to the word "scary". Notice "haunted", it is invalid because it's within a bracket.

Each additional set of parenthesis increases attention by a factor of 1.1, while on brackets the opposite. The effect is cumulative.

```text
I want to see a (((beautiful))) [[scary]] forest.
```

In this example, the model will give approximately 1.331 times more attention to "beautiful" `(1 * 1.1 * 1.1 * 1.1)` and approximately 0.751 times less attention to the word "scary" `(1 / 1.1 / 1.1)`.

Also, in a different matter to exceed the standard 75 token limit of SD. The `BREAK` keyword (in uppercase) can be use to fill the current chunk with padding characters and start a new chunk. Each chunk is processed independently using CLIP's Transformers neural network, and the results are concatenated before being fed into the next component of Stable Diffusion, the Unet.

```text
Once upon a time, in a land far, far away, there was a [long prompt with more than 75 tokens]... BREAK And so, the story continues with another chunk of text.
```

In this example, the prompt exceeds 75 tokens and is broken into chunks. The BREAK keyword is used to start a new chunk after the first part of the prompt.