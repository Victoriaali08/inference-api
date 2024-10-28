import os
from flask import Flask, request, send_file, jsonify

app = Flask(__name__)


@app.route("/synthesize", methods=["POST"])
def synthesize():
    print("hi")


def list_inference_api_files(directory):
    # 디렉토리 내의 모든 파일 및 하위 디렉토리 출력
    for root, dirs, files in os.walk(directory):
        level = root.replace(directory, "").count(os.sep)  # 현재 깊이 레벨
        indent = " " * 4 * (level)  # 들여쓰기
        print(f"{indent}{os.path.basename(root)}/")  # 디렉토리 이름 출력
        for file in files:
            print(f"{indent}    {file}")  # 파일 이름 출력


if __name__ == "__main__":
    # Inference API 폴더 내의 데이터 출력
    inference_api_directory = "/inference-api"
    print(f"Contents of {inference_api_directory}:")
    list_inference_api_files(inference_api_directory)

    app.run(host="0.0.0.0", port=4500)
