import streamlit as st
import os

from langchain.agents import initialize_agent, AgentType
from langchain.callbacks import StreamlitCallbackHandler
from langchain.tools import DuckDuckGoSearchRun

with st.sidebar:
    gemini_api_key = st.text_input("Google Gemini API Key", type="password")
    os.environ["GOOGLE_API_KEY"] = gemini_api_key
    "[Get an Google Gemini API key](https://aistudio.google.com/app/apikey)"

if "messages" not in st.session_state:
    st.session_state["messages"] = [
        {"role": "assistant",
            "content": "Hi, I'm a chatbot who can search the web. How can I help you?"}
    ]

for msg in st.session_state.messages:
    st.chat_message(msg["role"]).write(msg["content"])

if prompt := st.chat_input(placeholder="Who won the Men's U.S. Open in 2020?"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    st.chat_message("user").write(prompt)

    if not gemini_api_key:
        st.info("Please add your Google Gemini API key to continue.")
        st.stop()

    search = DuckDuckGoSearchRun(name="Search")
    search_agent = initialize_agent([search], llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, handle_parsing_errors=True)
    with st.chat_message("assistant"):
        st_cb = StreamlitCallbackHandler(st.container(), expand_new_thoughts=False)
        response = search_agent.run(st.session_state.messages, callbacks=st_cb)
        st.session_state.messages.append({"role": "assistant", "content": response})
        st.write(response)
