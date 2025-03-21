//
//  WWSimpleAI_ChatGPT.swift
//  WWSimpleAI_ChatGPT
//
//  Created by William.Weng on 2024/2/21.
//

import UIKit
import WWNetworking
import WWSimpleAI_Ollama

// MARK: - WWSimpleAI.ChatGPT
extension WWSimpleAI {
    
    // MARK: - WWSimpleChatGPT
    open class ChatGPT {
        
        public static let shared = ChatGPT()
        
        static let baseURL = "https://api.openai.com"
        
        static var version = "v1"
        static var apiKey = "<ApiKey>"
        
        public struct Model {}
        
        private init() {}
    }
}

// MARK: - 初始值設定 (static function)
public extension WWSimpleAI.ChatGPT {
    
    /// [參數設定](https://platform.openai.com/docs/api-reference/making-requests)
    /// - Parameters:
    ///   - apiKey: [String](https://platform.openai.com/account/api-keys)
    ///   - version: String
    static func configure(apiKey: String, version: String = "v1") {
        self.apiKey = apiKey
        self.version = version
    }
}

// MARK: - 開放工具
public extension WWSimpleAI.ChatGPT {
    
    /// 執行聊天功能
    /// - Parameters:
    ///   - model: WWSimpleAI.ChatGPT.Model.Chat
    ///   - role: String
    ///   - temperature: Double
    ///   - content: String
    /// - Returns: Result<String?, Error>
    func chat(model: WWSimpleAI.ChatGPT.Model.Chat = .v4o, role: String = "user", temperature: Double = 0.7, content: String) async -> Result<String?, Error> {
        let apiURL: WWSimpleAI.ChatGPT.API = .chat
        return await chat(apiURL: apiURL.value(), model: model.value(), role: role, temperature: temperature, content: content)
    }
    
    /// 文字轉語音
    /// - Parameters:
    ///   - model: WWSimpleAI.ChatGPT.Model.TTS
    ///   - voice: WWSimpleAI.ChatGPT.Model.Voice
    ///   - speed: Double
    ///   - input: Double
    /// - Returns: Result<Data?, Error>
    func speech(model: WWSimpleAI.ChatGPT.Model.TTS = .v1, voice: WWSimpleAI.ChatGPT.Model.Voice = .alloy, speed: Double = 1.0, input: String) async -> Result<Data?, Error> {
        let apiURL: WWSimpleAI.ChatGPT.API = .speech
        return await speech(apiURL: apiURL.value(), model: model.value(), voice: voice.value(), speed: speed, input: input)
    }
    
    /// 語音轉文字
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 語音模組
    ///   - audio: WWSimpleAI.ChatGPT.ChatGPT.WhisperAudio
    /// - Returns: Result<String?, Error>
    func whisper(model: WWSimpleAI.ChatGPT.Model.Whisper = .v1, audio: WWSimpleAI.ChatGPT.WhisperAudio) async -> Result<String?, Error> {
        let apiURL: WWSimpleAI.ChatGPT.API = .whisper
        return await whisper(apiURL: apiURL.value(), model: model.value(), audioType: audio.type, data: audio.data)
    }
    
    /// 文字生成圖片
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 圖片模型
    ///   - prompt: 圖片述敘文字
    ///   - n: 生成張數 (1-10)
    ///   - size: 圖片大小
    /// - Returns: Result<[Any]?, Error>
    func image(model: WWSimpleAI.ChatGPT.Model.ImageModel = .v2, prompt: String, n: Int = 1, size: WWSimpleAI.ChatGPT.Model.ImageSize = ._256x256) async -> Result<[Any]?, Error> {
        let apiURL: WWSimpleAI.ChatGPT.API = .images
        return await image(apiURL: apiURL.value(), model: model.value(), prompt: prompt, n: n, size: size.value())
    }
}

// MARK: - 小工具
private extension WWSimpleAI.ChatGPT {
    
    /// 執行API功能
    /// - Parameters:
    ///   - httpMethod: WWNetworking.Constant.HttpMethod
    ///   - apiURL: String
    ///   - httpBody: String
    /// - Returns: Result<WWNetworking.ResponseInformation, Error>
    func execute(httpMethod: WWNetworking.HttpMethod = .POST, apiURL: String, httpBody: String?) async -> Result<WWNetworking.ResponseInformation, Error> {
        
        let headers = authorizationHeaders()
        let result = await WWNetworking.shared.request(httpMethod: httpMethod, urlString: apiURL, contentType: .json, paramaters: nil, headers: headers, httpBodyType: .string(httpBody))
        
        return result
    }
    
    /// 模型列表
    /// - Returns: Result<WWNetworking.ResponseInformation, Error>
    func models() async -> Result<Any?, Error> {
        
        let apiURL: WWSimpleAI.ChatGPT.API = .models
        let result = await execute(httpMethod: .GET, apiURL: apiURL.value(), httpBody: nil)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let data = info.data,
                  let jsonObject = data._jsonObject()
            else {
                return .success(nil)
            }
            
            return .success(jsonObject)
        }
    }
    
    /// 安全認證Header
    /// - Returns: [String: String?]
    func authorizationHeaders() -> [String: String?] {
        let headers: [String: String?] = ["Authorization": "Bearer \(WWSimpleAI.ChatGPT.apiKey)"]
        return headers
    }
    
    /// [聊天功能](https://platform.openai.com/docs/api-reference/chat/create)
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: [GPT模型](https://platform.openai.com/docs/models/gpt-3-5-turbo)
    ///   - content: 提問文字
    ///   - role: 角色名稱
    ///   - temperature: 準確性 / 機率分佈
    /// - Returns: Result<String?, Error>
    func chat(apiURL: String, model: String, role: String, temperature: Double, content: String) async -> Result<String?, Error> {
        
        let httpBody = """
        {
          "model": "\(model)",
          "messages": [{"role": "\(role)","content": "\(content)"}],
          "temperature": \(temperature)
        }
        """
        
        let result = await execute(apiURL: apiURL, httpBody: httpBody)
        var content: String?
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let dictionary = info.data?._jsonObject() as? [String: Any] else { return .success(content) }
            
            if let error = dictionary["error"] as? [String: Any] { return .failure(WWSimpleAI.ChatGPT.ErrorMessage.error(error)) }
            
            guard let _choices = dictionary["choices"] as? [Any],
                  let _choice = _choices.first as? [String: Any],
                  let _message = _choice["message"] as? [String: Any],
                  let _content = _message["content"] as? String
            else {
                return .success(content)
            }
            
            content = _content
        }
        
        return .success(content)
    }
    
    /// 文字轉語音
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 聲音模組
    ///   - voice: 說話語音
    ///   - speed: 聲音語速
    ///   - input: 轉換文字
    /// - Returns: Result<Data?, Error>
    func speech(apiURL: String, model: String, voice: String, speed: Double, input: String) async -> Result<Data?, Error> {
        
        let httpBody = """
        {
          "model": "\(model)",
          "input": "\(input)",
          "voice": "\(voice)",
          "speed": \(speed)
        }
        """
        
        let result = await execute(apiURL: apiURL, httpBody: httpBody)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info): return .success(info.data)
        }
    }
    
    /// 語音轉文字
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 語音模組
    ///   - audioType: 語音資料類型
    ///   - data: 語音資料
    /// - Returns: Result<String?, Error>
    func whisper(apiURL: String, model: String, audioType: WWSimpleAI.ChatGPT.Model.WhisperAudioType = .mp3, data: Data) async -> Result<String?, Error>  {
        
        let headers = authorizationHeaders()
        let formData: WWNetworking.FormDataInformation = (name: "file", filename: "whisper.\(audioType.rawValue)", contentType: audioType.contentType(), data: data)
        let parameters = ["model": model]
        let result = await WWNetworking.shared.upload(urlString: apiURL, formData: formData, parameters: parameters, headers: headers)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let dictionary = info.data?._jsonObject() as? [String: Any] else { return .failure(WWSimpleAI.ChatGPT.ErrorMessage.error(["message": "The value is not JSON."])) }
            
            guard let text = dictionary["text"] as? String else {
                
                if let error = dictionary["error"] as? [String: Any] {
                    return .failure(WWSimpleAI.ChatGPT.ErrorMessage.error(error))
                }
                
                return .failure(WWSimpleAI.ChatGPT.ErrorMessage.error(["message": "Unknow."]))
            }
            
            return .success(text)
        }
    }
    
    /// 文字生成圖片
    /// - Parameters:
    ///   - apiURL: String
    ///   - model: 圖片模型
    ///   - prompt: 圖片述敘文字
    ///   - n: 生成張數 (1-10)
    ///   - size: 圖片大小
    /// - Returns: Result<[Any]?, Error>
    func image(apiURL: String, model: String, prompt: String, n: Int, size: String) async -> Result<[Any]?, Error> {
        
        let httpBody = """
        {
            "model": "\(model)",
            "prompt": "\(prompt)",
            "n": \(n),
            "size": "\(size)"
        }
        """
                
        let result = await execute(apiURL: apiURL, httpBody: httpBody)
        
        switch result {
        case .failure(let error): return .failure(error)
        case .success(let info):
            
            guard let dictionary = info.data?._jsonObject() as? [String: Any] else { return .success(nil) }
            
            if let error = dictionary["error"] as? [String: Any] { return .failure(WWSimpleAI.ChatGPT.ErrorMessage.error(error)) }
            if let datas = dictionary["data"] as? [Any] { return .success(datas) }
            
            return .success(nil)
        }
    }
}
