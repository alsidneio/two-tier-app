
import streamlit as st


st.title("Wiz System Demo")

if "uploaded_files" in st.session_state: 
    st.session_state.uploaded_files = []



with st.form(key="upload_file", clear_on_submit=True):
    uploaded_files = st.file_uploader(
    "Upload data", accept_multiple_files=True
    )

    send_files = st.form_submit_button(label="Upload Files")
    if send_files: 
        for uploaded_file in uploaded_files:
            
     