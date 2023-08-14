//
// minizip-ngをSwiftから使う
//
import Minizip
import Foundation

func main(){
    // 対象のファイル
    guard let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
        exit(EXIT_FAILURE)
    }
    let targetFileURL = desktopURL.appendingPathComponent("アーカイブ.zip")
    let targetFilePath: String
    if #available(macOS 13, *) {
        targetFilePath = targetFileURL.path(percentEncoded: false)
    } else {
        targetFilePath = targetFileURL.path
    }
    
    // ハンドラを初期化
    print("Initialize zip reader")
    var reader = mz_zip_reader_create()
    if reader == nil{
        print("handler initialize error")
        return
    }
    
    // zip_readerでファイルをオープン
    print("Open file: \(targetFilePath)")
    let didOpenFile = targetFilePath.withCString({ ptr in
        return mz_zip_reader_open_file(reader, ptr)
    })
    guard didOpenFile == MZ_OK else {
        print("failed to open file: \(didOpenFile)")
        mz_zip_reader_delete(&reader)
        return
    }
    
    // 最初のエントリに移動
    print("Move to first entry")
    let didGoFirstEntry = mz_zip_reader_goto_first_entry(reader)
    if didGoFirstEntry != MZ_OK && didGoFirstEntry != MZ_END_OF_LIST {
        print("Failed to move first entry: \(didGoFirstEntry)")
        mz_zip_reader_delete(&reader)
        return
    }
    
    // 現在のエントリの情報を取得するクロージャ
    let getFileInfoFromCurrentEntry: (_ reader: UnsafeMutableRawPointer?) -> mz_zip_file? = {reader in
        var zipfilePtr: UnsafeMutablePointer<mz_zip_file>? = .allocate(capacity: 1)
        zipfilePtr?.initialize(to: mz_zip_file())
        let didGetFileInfo = mz_zip_reader_entry_get_info(reader, &zipfilePtr)
        print(didGetFileInfo)
        guard didGetFileInfo == MZ_OK else{return nil}
        let zipfile = zipfilePtr?.pointee
        zipfilePtr?.deallocate()
        return zipfile
    }
    
    // イテレーション
    while true {
        
        // ファイル情報を取得
        guard let fileInfo = getFileInfoFromCurrentEntry(reader) else {
            print("Failed to load file info of current entry")
            break
        }

        // とりあえずファイル名を並べる
        if let fileName = String(cString: fileInfo.filename, encoding: .utf8){
            print(fileName)
        }else{
            print("failed to get file name")
        }
        
        // 次のエントリへ
        let didGoNextEntry = mz_zip_reader_goto_next_entry(reader)
        if didGoNextEntry != MZ_OK && didGoNextEntry != MZ_END_OF_LIST{
            print("failed to go next entry: \(didGoNextEntry)")
            break
        }
    }
    
    // 後片付け
//        mz_zip_reader_delete(&reader)
}

main()
