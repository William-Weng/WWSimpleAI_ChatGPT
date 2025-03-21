//
//  Constant.swift
//  WWSimpleAI_ChatGPT
//
//  Created by William.Weng on 2024/2/21.
//

import UIKit
import WWNetworking
import WWSimpleAI_Ollama

public extension WWSimpleAI.ChatGPT {
    
    typealias WhisperAudio = (type: WWSimpleAI.ChatGPT.Model.WhisperAudioType, data: Data)     // 語音轉文字 (WhisperAudioType, Data)
}

// MARK: - enum
public extension WWSimpleAI.ChatGPT {
    
    /// API功能
    enum API {
        
        case chat                   // 聊天問答
        case speech                 // 文字轉語音
        case whisper                // 語音轉文字
        case images                 // 圖片生成
        case models                 // 模型列表
        case embeddings             // 將文字轉為數字表示 (？)
        case fineTuning             // 訓練模型微調 (？)
        case files                  // 檔案上傳 / 下載 (？)
        case moderations            // 文字是否違反OpenAI的內容政策進行分類 (？)
        case assistants             // 建立一個助手 (？)
        case threads                // 建立線程 (？)
        case custom(_ path: String) // 自訂路徑 (audio/translations)
        
        /// 取得url
        /// - Returns: String
        func value() -> String {
            
            let path: String
            
            switch self {
            case .chat: path = "chat/completions"
            case .speech: path = "audio/speech"
            case .whisper: path = "audio/transcriptions"
            case .images: path = "images/generations"
            case .embeddings: path = "embeddings"
            case .fineTuning: path = "fine_tuning/jobs"
            case .files: path = "files"
            case .models: path = "models"
            case .moderations: path = "moderations"
            case .assistants: path = "assistants"
            case .threads: path = "threads"
            case .custom(let _path): path = _path
            }
            
            return "\(WWSimpleAI.ChatGPT.baseURL)/\(WWSimpleAI.ChatGPT.version)/\(path)"
        }
    }
    
    /// ChatGPT錯誤
    enum ErrorMessage: Error {
        case error(_ error: [String: Any])
    }
}

// MARK: - 模組
public extension WWSimpleAI.ChatGPT.Model {
    
    /// [聊天模組](https://platform.openai.com/docs/models)
    enum Chat {
        
        case v3_5
        case v4
        case v4o
        case v4o_mini
        case vo1
        case vo1_mini
        case custom(_ model: String)
        
        /// 取得GPT模組名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .v3_5: return "gpt-3.5-turbo"
            case .v4: return "gpt-4-turbo"
            case .v4o: return "gpt-4o"
            case .v4o_mini: return "gpt-4o-mini"
            case .vo1: return "o1-preview"
            case .vo1_mini: return "o1-mini"
            case .custom(let model): return model
            }
        }
    }
    
    /// 圖片生成模組
    enum ImageModel {
        
        case v2
        case v3
        case custom(_ model: String)
        
        /// 模型名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .v2: return "dall-e-2"
            case .v3: return "dall-e-3"
            case .custom(let model): return model
            }
        }
    }
    
    /// 語音模組
    enum TTS {
        
        case v1
        case v1_hd
        case custom(_ model: String)
        
        /// 取得語音模組名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .v1: return "tts-1"
            case .v1_hd: return "tts-1-hd"
            case .custom(let model): return model
            }
        }
    }
    
    /// 聲音模組
    enum Voice {
        
        case alloy
        case echo
        case fable
        case onyx
        case nova
        case shimmer
        case custom(_ model: String)
        
        /// 取得聲音模組名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .alloy: return "alloy"
            case .echo: return "echo"
            case .fable: return "fable"
            case .onyx: return "onyx"
            case .nova: return "nova"
            case .shimmer: return "shimmer"
            case .custom(let model): return model
            }
        }
    }
    
    /// 耳語模組
    enum Whisper {
        
        case v1
        case custom(_ model: String)
        
        /// 取得語音轉文字模組名稱
        /// - Returns: String
        func value() -> String {
            switch self {
            case .v1: return "whisper-1"
            case .custom(let model): return model
            }
        }
    }
    
    /// 耳語模組能轉換的類型
    enum WhisperAudioType: String {
        
        case flac
        case mp3
        case mp4
        case mpeg
        case mpga
        case m4a
        case ogg
        case wav
        case webm
        
        /// [取得MIME類型文字](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types)
        /// - Returns: [String](https://www.iana.org/assignments/media-types/media-types.xhtml)
        func contentType() -> WWNetworking.ContentType {
            
            let mime: WWNetworking.ContentType
            
            switch self {
            case .mp3: mime = .mp3
            case .mpeg: mime = .mpeg
            case .mpga: mime = .mpga
            case .mp4: mime = .mp4
            case .ogg: mime = .ogg
            case .wav: mime = .wav
            case .webm: mime = .webm
            case .m4a: mime = .m4a
            case .flac: mime = .flac
            }
            
            return mime
        }
    }
    
    /// 圖片生成支援的尺寸
    enum ImageSize {
        
        case _256x256
        case _512x512
        case _1024x1024
        case _1024x1792
        case _1792x1024
        case custom(_ size: String)
        
        /// 尺寸文字
        /// - Returns: String
        func value() -> String {
            switch self {
            case ._256x256: return "256x256"
            case ._512x512: return "512x512"
            case ._1024x1024: return "1024x1024"
            case ._1024x1792: return "1024x1792"
            case ._1792x1024: return "1792x1024"
            case .custom(let size): return size
            }
        }
    }
}
