const { GoogleGenerativeAI } = require("@google/generative-ai");

const generationConfig = {
  temperature: 0.7,
  candidateCount: 1,
  topK: 40,
  topP: 0.95,
  maxOutputTokens: 1024,
};

const safetySettings = [
  {
    category: 'HARM_CATEGORY_DANGEROUS_CONTENT',
    threshold: 'BLOCK_NONE'
  },
];

const genAI = new GoogleGenerativeAI(process.env.API_KEY);

const model = genAI.getGenerativeModel({
  model: "gemini-pro",
});

model.generateContent({
  generationConfig,
  safetySettings,
  contents: [
    {
      role: "user",
      parts: [
        { text: 'On what planet do humans live?' },
      ],
    },
  ],
}).then(result => {
  console.log(JSON.stringify(result, null, 2));
});
