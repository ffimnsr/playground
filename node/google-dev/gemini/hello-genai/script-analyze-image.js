const { GoogleGenerativeAI } = require("@google/generative-ai");
const { join } = require('path');
const fs = require('fs');

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
  model: "gemini-pro-vision",
});

const base64Image = Buffer.from(fs.readFileSync(join(__dirname, 'cat.png'))).toString("base64");

model.generateContent({
  generationConfig,
  safetySettings,
  contents: [
    {
      role: "user",
      parts: [
        { text: 'Can you see an image attached to this message?' },
        {
          inlineData: {
            mimeType: 'image/png',
            data: base64Image
          }
        },
      ],
    },
  ],
}).then(result => {
  console.log(JSON.stringify(result, null, 2));
});
