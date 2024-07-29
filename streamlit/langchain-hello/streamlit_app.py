from langchain_google_genai import ChatGoogleGenerativeAI

import streamlit as st
import os


st.set_page_config(page_title="🦜🔗 Langchain Hello")
st.title("🦜🔗 Langchain Hello")

with st.sidebar:
  gemini_api_key = st.text_input("Google Gemini API Key", type="password")
  os.environ["GOOGLE_API_KEY"] = gemini_api_key
  "[Get an Google Gemini API key](https://aistudio.google.com/app/apikey)"

def generate_response(input_text):
  llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",
    temperature=0.8
  )
  message = llm.invoke(input_text)
  st.info(message.content)

with st.form("my_form"):
  text = st.text_area("Enter query:", "What is the value of PI?")
  submitted = st.form_submit_button("Submit")
  if not gemini_api_key:
    st.info("Please add your Google Gemini API key to continue.")
  elif submitted:
    generate_response(text)
