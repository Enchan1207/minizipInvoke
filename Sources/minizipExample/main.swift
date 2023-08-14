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
    
    // イテレーション
    var canContinue: Int32 = MZ_OK
    while canContinue == MZ_OK {
        // ファイル情報を取得
        var zipfilePtr: UnsafeMutablePointer<mz_zip_file>? = nil
        canContinue = mz_zip_reader_entry_get_info(reader, &zipfilePtr)
        if(canContinue != MZ_OK){
            print("failed to get info of current entry")
            continue
        }
        let zipfile = zipfilePtr!.pointee
        
        // ファイル名を取得
        let filename = String(cString: zipfile.filename, encoding: .utf8)!
        print("  file: \(filename)")
        
        // 次のエントリへ
        canContinue = mz_zip_reader_goto_next_entry(reader)
        if canContinue != MZ_OK && canContinue != MZ_END_OF_LIST{
            print("failed to go next entry: \(canContinue)")
            break
        }
    }
    
    if canContinue == MZ_END_OF_LIST{
        print("iteration finished.")
    }else{
        print("iteration failed: \(canContinue)")
    }
    
    // 後片付け
    mz_zip_reader_delete(&reader)
}

main()
