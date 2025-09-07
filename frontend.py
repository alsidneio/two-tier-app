
import streamlit as st
import httpx


st.title("Wiz System Demo")

if "uploaded_files" in st.session_state: 
    st.session_state.uploaded_files = []



with st.form(key="upload_file", clear_on_submit=True):
    uploaded_files = st.file_uploader(
    "Upload data", accept_multiple_files=True
    )

    send_files = st.form_submit_button(label="Upload Files", type="primary")
    if send_files: 
        # Preparing files for upload
        files = []
        for uploaded_file in uploaded_files:
            files.append(
                            ("files", (uploaded_file.name, uploaded_file.getvalue(), uploaded_file.type))
                        )
        
        with st.spinner(f"Uploading {len(uploaded_files)} files..."):
            resp = httpx.post('http://127.0.0.1:8000/uploadfiles/',files=files)
            
        if resp.status_code == 200:
            print(resp.json())
            st.success(" All files uploaded successfully!", icon="✅")
 