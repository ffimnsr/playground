import streamlit as st


st.title("Langchain Hello")

with st.form("my_form"):
  text = st.text_area("Enter text:", "What")
  submit = st.form_submit_button("Submit")
