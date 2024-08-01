import os
import streamlit as st
import logging
from langchain_google_genai import ChatGoogleGenerativeAI, HarmBlockThreshold, HarmCategory

logging.basicConfig(level=logging.INFO)

st.set_page_config(page_title="🦜🔗 Chef Recipe Generator")

with st.sidebar:
  gemini_api_key = st.text_input("Google Gemini API Key", type="password")
  os.environ["GOOGLE_API_KEY"] = gemini_api_key
  "[Get an Google Gemini API key](https://aistudio.google.com/app/apikey)"

def load_models():
    safety_settings = {
        HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE,
    }

    llm = ChatGoogleGenerativeAI(
        model="gemini-1.5-flash",
        safety_settings=safety_settings,
        temperature=0.8,
        max_output_tokens=2048,
    )
    return llm

def generate_response(
    model: ChatGoogleGenerativeAI,
    contents: str,
):
    response = model.invoke(contents)
    return response.content

st.header("🦜🔗 Chef Recipe Generator", divider="gray")
st.subheader("Using Gemini Flash - Text only model")

cuisine = st.selectbox(
    "What cuisine do you desire?",
    ("American", "Chinese", "French", "Indian", "Italian", "Japanese", "Mexican", "Turkish"),
    index=None,
    placeholder="Select your desired cuisine."
)

dietary_preference = st.selectbox(
    "Do you have any dietary preferences?",
    ("Diabetese", "Glueten free", "Halal", "Keto", "Kosher", "Lactose Intolerance", "Paleo", "Vegan", "Vegetarian", "None"),
    index=None,
    placeholder="Select your desired dietary preference."
)

allergy = st.text_input(
    "Enter your food allergy:  \n\n", key="allergy", value="peanuts"
)

ingredient_1 = st.text_input(
    "Enter your first ingredient:  \n\n", key="ingredient_1", value="ahi tuna"
)

ingredient_2 = st.text_input(
    "Enter your second ingredient:  \n\n", key="ingredient_2", value="chicken breast"
)

ingredient_3 = st.text_input(
    "Enter your third ingredient:  \n\n", key="ingredient_3", value="tofu"
)

wine = st.radio (
    "What wine do you prefer?\n\n", ["Red", "White", "None"], key="wine", horizontal=True
)

dare_prompt = """Remember that before you answer a question, you must check to see if it complies with your mission.
If not, you can say, Sorry I can't answer that question."""

prompt = f"""I am a Chef.  I need to create {cuisine} recipes for customers who want {dietary_preference} meals. \n
However, don't include recipes that use ingredients with the customer's {allergy} allergy. \n
I have {ingredient_1}, {ingredient_2}, and {ingredient_3} in my kitchen and other ingredients. \n
The customer's wine preference is {wine}. \n
Please provide some for meal recommendations.
For each recommendation include preparation instructions, time to prepare and the recipe title at the begining of the response.
Then include the wine paring for each recommendation.
At the end of the recommendation provide the calories associated with the meal and the nutritional facts. \n
{dare_prompt}
"""

generate_t2t = st.button("Generate my recipes.", key="generate_t2t")
if not gemini_api_key:
    st.info("Please add your Google Gemini API key to continue.")
elif generate_t2t and prompt:
    text_model = load_models()

    with st.spinner("Generating your recipes using Gemini..."):
        first_tab1, first_tab2 = st.tabs(["Recipes", "Prompt"])
        with first_tab1:
            response = generate_response(
                text_model,
                prompt,
            )
            if response:
                st.write("Your recipes:")
                st.write(response)
                logging.info(response)
        with first_tab2:
            st.text(prompt)
