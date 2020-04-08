//
//  YQMainViewController
//  LocalizationToolForValue
//
//  Created by sungrow on 2018/2/8.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Cocoa

enum ToolFunc: Int {
    /// 输出 I18N 开头的key
    case inputI18N = 0
    /// 输出 非I18N 开头的key
    case inputNOI18N
    /// 输出 key相同 - value相同的key
    case inputKeySameValueSame
    /// 输出 key不同 - value相同的key
    case inputKeySameValueDifferent
    /// 输出 key相同同 - value不同的key
    case inputKeyDifferentValueSame
    /// 输出目标文件中存在, 源文件不存在的key
    case inputTargetExistOriginalNoExist
    /// 使用目标文件的key 替换源文件的key; 使用 源文件key 和 目标文件的value 匹配
    case replaceKeyUseTargetKey
}

class YQMainViewController: NSViewController {

    @IBOutlet weak var sourceTableView: NSTableView!
    @IBOutlet weak var targetTableView: NSTableView!
    
    /// 局部常量
    private let settingViewHeight: CGFloat = 300
    
    /// 控件属性
    @IBOutlet weak var settingView: NSView!
    @IBOutlet weak var sourceDragDropView: YQDragDropView!
    @IBOutlet weak var targetDragDropView: YQDragDropView!
    @IBOutlet weak var bgGradientView: YQGradientView!
    
    @IBOutlet weak var starExecuteBTN: NSButton!
    @IBOutlet weak var executeIndicator: NSProgressIndicator!
    @IBOutlet weak var sourceMessageLBL: NSTextField!
    @IBOutlet weak var targetMessageLBL: NSTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var outFolderNameTF: NSTextField!
    @IBOutlet weak var outPathTF: NSTextField!
    @IBOutlet weak var selectPathBTN: NSButton!
    
    private lazy var sourceDataList: [YQFileModel] = [YQFileModel]()
    private lazy var targetDataList: [YQFileModel] = [YQFileModel]()
    
    @IBOutlet weak var inputI18NRadio: NSButton!
    private lazy var toolFucn: ToolFunc = .inputI18N
    private lazy var selectRadio: NSButton = inputI18NRadio
    
    fileprivate lazy var sourceDelegate: YQTableViewDelegate = {
        let delegate = YQTableViewDelegate()
        delegate.tableview = sourceTableView
        delegate.fileModels = sourceDataList
        return delegate
    }()
    
    fileprivate lazy var popOver: NSPopover = {
        let popView = NSPopover()
        popView.contentViewController = YQQuestionViewController()
        popView.behavior = .transient
        popView.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        return popView
    }()
    
    private lazy var targetDelegate: YQTableViewDelegate = {
        let delegate = YQTableViewDelegate()
        delegate.tableview = targetTableView
        delegate.fileModels = targetDataList
        return delegate
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bottomConstraint.constant = 0
        
        sourceDragDropView.delegate = self
        targetDragDropView.delegate = self
        
        sourceTableView.delegate = sourceDelegate
        sourceTableView.dataSource = sourceDelegate
        
        targetTableView.delegate = targetDelegate
        targetTableView.dataSource = targetDelegate
        
        configOutpath()
        outFolderNameTF.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func radioAction(_ sender: NSButton) {
        if selectRadio == sender {
            return
        }
        selectRadio.state = .off
        sender.state = sender.state == .off ? .off : .on
        selectRadio = sender
        toolFucn = ToolFunc(rawValue: sender.tag - 2000)!
    }
    
    @IBAction func startAction(_ sender: NSButton) {
        switch toolFucn {
        case .inputI18N:
            inputI18NAction()
            break
        case .inputNOI18N:
            inputNOI18NAction()
            break
        case .inputKeySameValueSame:
            inputKeySameValueSameAction()
            break
        case .inputKeySameValueDifferent:
            inputKeySameValueDifferent()
            break
        case .inputKeyDifferentValueSame:
            inputKeyDifferentValueSame()
            break
        case .inputTargetExistOriginalNoExist:
            inputTargetExistOriginalNoExistAction()
            break
        case .replaceKeyUseTargetKey:
            replaceKeyUseTargetKeyAction()
            break
        }
    }
    
    @IBAction func selectPathAction(_ sender: NSButton) {
        let path = openPanel(canChooseFile: false)
        JointManager.shared.homePath = path
        configOutpath()
    }
    
    @IBAction func questionAction(_ sender: NSButton) {
        popOver.show(relativeTo: sender.bounds, of: sender, preferredEdge: NSRectEdge.maxY)
    }
    
    @IBAction func openOutFolderAction(_ sender: NSButton) {
        NSWorkspace.shared.openFile(JointManager.shared.outPath)
    }
    
    @IBAction func restoreDefaultAction(_ sender: NSButton) {
        JointManager.shared.restoreDefaultPath()
        configOutpath()
    }
    
    @IBAction func settingAction(_ sender: NSButton) {
        if bottomConstraint.constant > 0 {
            bottomConstraint.constant = 0
        } else {
            bottomConstraint.constant = settingViewHeight
        }
        NSAnimationContext.runAnimationGroup({ (context) in
            context.allowsImplicitAnimation = true
            context.duration = 0.25
        }, completionHandler: nil)
    }
    
    @IBAction func clearSourceDataList(_ sender: NSButton) {
        sourceDataList.removeAll()
        reloadSourceTableVC()
    }
    
    @IBAction func clearTargetDataList(_ sender: NSButton) {
        targetDataList.removeAll()
        reloadTargetTableVC()
    }
    
}

// MARK: - private Action
extension YQMainViewController {
    /// 开始执行
    private func starExecute() {
        DispatchQueue.main.async {
            self.starExecuteBTN.isHidden = true
            self.executeIndicator.isHidden = false
            self.executeIndicator.startAnimation(nil)
        }
        showMessage("开始处理", label: self.targetMessageLBL)
        showMessage("开始处理", label: self.sourceMessageLBL)
    }
    
    /// 结束执行
    private func endExecute() {
        DispatchQueue.main.async {
            self.starExecuteBTN.isHidden = false
            self.executeIndicator.isHidden = true
            self.executeIndicator.stopAnimation(nil)
        }
        showMessage("处理完成", label: self.targetMessageLBL)
        showMessage("处理完成", label: self.sourceMessageLBL)
    }
    
    /// 显示信息
    ///
    /// - Parameters:
    ///   - message: 信息
    ///   - label: 标签
    private func showMessage(_ message: String, label: NSTextField) {
        DispatchQueue.main.async {
            label.stringValue = message
        }
    }
    
    @discardableResult
    private func allKeyValueModels(_ fileModels: [YQFileModel], forEach: ((KeyValueModel) -> Bool)? = nil) -> [KeyValueModel] {
        var keyValueModels = [KeyValueModel]()
        fileModels.forEach { (fileModel) in
            fileModel.enumeratorFile({ (filePath) in
                let models = SplitManager.shared.split(YQFileModel(filePath: filePath), forEach: forEach)
                keyValueModels = keyValueModels + models
            })
        }
        return keyValueModels
    }
    
    private func reloadSourceTableVC() {
        sourceDragDropView.isHidden = sourceDataList.count > 0
        sourceTableView.isHidden = !sourceDragDropView.isHidden
        sourceDelegate.fileModels = sourceDataList
    }
    
    private func reloadTargetTableVC() {
        targetDragDropView.isHidden = targetDataList.count > 0
        targetTableView.isHidden = !targetDragDropView.isHidden
        targetDelegate.fileModels = targetDataList
    }
    
    private func configOutpath() {
        outFolderNameTF.stringValue = JointManager.shared.outFolderName
        outPathTF.placeholderString = JointManager.shared.outPath
    }
    
    /// 从Finder中选择文件/文件夹
    ///
    /// - Parameter canChooseFile: 是否是文件
    /// - Returns: 文件/文件夹路径
    fileprivate func openPanel(canChooseFile: Bool) -> String {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = !canChooseFile
        openPanel.canChooseFiles = canChooseFile
        openPanel.canCreateDirectories = true
        openPanel.title = "选择输出路径"
        openPanel.message = "转换后的资源文件将会保存到该目录下"
        if openPanel.runModal() == .OK {
            let path = openPanel.urls.first?.absoluteString.components(separatedBy: ":").last?.removingPercentEncoding as NSString?
            return path?.expandingTildeInPath ?? ""
        }
        return ""
    }
}

// MARK: - ToolFunc
extension YQMainViewController {
    /// 输出 I18N 开头的词条
    fileprivate func inputI18NAction() {
        starExecute()
        DispatchQueue.global().async {
            let sourceKeyValueModels = self.allKeyValueModels(self.sourceDataList)
            var content = ""
            sourceKeyValueModels.forEach({ (sourceKeyValueModel) in
                self.showMessage("正在处理:" + sourceKeyValueModel.key, label: self.sourceMessageLBL)
                if sourceKeyValueModel.key.lowercased().hasPrefix("i18n") {
                    content += "\"\(sourceKeyValueModel.key)\" = \"\(sourceKeyValueModel.value)\";\n"
                }
            })
            JointManager.shared.Joint("\(self.toolFucn)", content: content)
            self.endExecute()
        }
    }
    
    /// 输出 非I18N 开头的词条
    fileprivate func inputNOI18NAction() {
        starExecute()
        DispatchQueue.global().async {
            let sourceKeyValueModels = self.allKeyValueModels(self.sourceDataList)
            var content = ""
            sourceKeyValueModels.forEach({ (sourceKeyValueModel) in
                self.showMessage("正在处理:" + sourceKeyValueModel.key, label: self.sourceMessageLBL)
                if !sourceKeyValueModel.key.lowercased().hasPrefix("i18n") {
                    content += "\"\(sourceKeyValueModel.key)\" = \"\(sourceKeyValueModel.value)\";\n"
                }
            })
            JointManager.shared.Joint("\(self.toolFucn)", content: content)
            self.endExecute()
        }
    }
    
    /// 输出 key 相同  value 相同的 词条
    fileprivate func inputKeySameValueSameAction() {
        starExecute()
        let sourceValueModels = allKeyValueModels(sourceDataList)
        DispatchQueue.global().async {
            var repeatKeys: [String] = []
            var content = ""
            sourceValueModels.forEach { (targetModel) in
                sourceValueModels.forEach({ (sourceModel) in
                    if targetModel.key == sourceModel.key &&
                        targetModel.value == sourceModel.value &&
                        targetModel.filePath! != sourceModel.filePath! &&
                        !repeatKeys.contains(sourceModel.key) &&
                        !repeatKeys.contains(targetModel.key) {
                        repeatKeys.append(sourceModel.key)
                        repeatKeys.append(targetModel.key)
                        content += "\"\(targetModel.key)\" = \"\(sourceModel.value)\";\n"
                    }
                })
            }
            JointManager.shared.Joint("\(self.toolFucn)", content: content)
            self.endExecute()
        }
    }
    
    /// 输出 key 相同  value 不同的 词条
    fileprivate func inputKeySameValueDifferent() {
        starExecute()
        let sourceValueModels = allKeyValueModels(sourceDataList)
        DispatchQueue.global().async {
            var repeatKeys: [String] = []
            var content = ""
            sourceValueModels.forEach { (targetModel) in
                sourceValueModels.forEach({ (sourceModel) in
                    if targetModel.key == sourceModel.key &&
                        targetModel.value != sourceModel.value &&
                        targetModel.filePath! != sourceModel.filePath! &&
                        !repeatKeys.contains(sourceModel.key) &&
                        !repeatKeys.contains(targetModel.key) {
                        repeatKeys.append(sourceModel.key)
                        repeatKeys.append(targetModel.key)
                        content += "\"\(targetModel.key)\" = \"\(sourceModel.value)\";\n"
                    }
                })
            }
            JointManager.shared.Joint("\(self.toolFucn)", content: content)
            self.endExecute()
        }
    }
    
    /// 输出 key 不同  value 相同的 词条
    fileprivate func inputKeyDifferentValueSame() {
        starExecute()
        let sourceValueModels = allKeyValueModels(sourceDataList)
        DispatchQueue.global().async {
            var repeatKeys: [String] = []
            var content = ""
            sourceValueModels.forEach { (targetModel) in
                sourceValueModels.forEach({ (sourceModel) in
                    if targetModel.key != sourceModel.key &&
                        targetModel.value == sourceModel.value &&
                        targetModel.filePath! != sourceModel.filePath! &&
                        !repeatKeys.contains(sourceModel.key) &&
                        !repeatKeys.contains(targetModel.key) {
                        repeatKeys.append(sourceModel.key)
                        repeatKeys.append(targetModel.key)
                        content += "\"\(targetModel.key)\" = \"\(sourceModel.value)\";\n"
                    }
                })
            }
            JointManager.shared.Joint("\(self.toolFucn)", content: content)
            self.endExecute()
        }
    }
    
    /// 输出 目标文件中存在, 源文件中不存在的 词条
    fileprivate func inputTargetExistOriginalNoExistAction() {
        starExecute()
        DispatchQueue.global().async {
            let targetKeyValueModels = self.allKeyValueModels(self.targetDataList)
            let sourceKeyValueModels = self.allKeyValueModels(self.sourceDataList)
            var content = ""
            var androidContent = ""
            targetKeyValueModels.forEach({ (targetKeyValueModel) in
                self.showMessage("正在处理:" + targetKeyValueModel.key, label: self.targetMessageLBL)
                var isUsedKey = false
                for sourceKeyValueModel in sourceKeyValueModels {
                    self.showMessage("正在处理:" + sourceKeyValueModel.key, label: self.sourceMessageLBL)
                    if targetKeyValueModel.key == sourceKeyValueModel.key {
                        isUsedKey = true
                        break;
                    }
                }
                if !isUsedKey {
                    content += "\"\(targetKeyValueModel.key)\" = \"\(targetKeyValueModel.value)\";\n"
                    var value = targetKeyValueModel.value
                    value = value.replacingOccurrences(of: "<", with: "&lt;")
                    value = value.replacingOccurrences(of: ">", with: "&gt;")
                    androidContent = androidContent + "<string name=\"" + targetKeyValueModel.key + "\">" + targetKeyValueModel.value + "</string>" + "\n"
                }
            })
            JointManager.shared.Joint("\(self.toolFucn)", content: content)
            JointManager.shared.Joint("android.xml", content: androidContent)
            self.endExecute()
        }
    }
    
    /// 使用目标文件中的key 替换 源文件中的 key; 通过目标文件的value 和资源文件的key 去匹配
    fileprivate func replaceKeyUseTargetKeyAction() {
        starExecute()
        let targetKeyValueModels = allKeyValueModels(targetDataList)
        DispatchQueue.global().async {
            targetKeyValueModels.forEach({ (targetKeyValueModel) in
                self.showMessage("正在处理:" + targetKeyValueModel.key, label: self.targetMessageLBL)
                self.allKeyValueModels(self.sourceDataList, forEach: { (sourceKeyValueModel) -> Bool in
                    if sourceKeyValueModel.key.lowercased().hasPrefix("i18n") {
                        self.showMessage("正在处理:" + sourceKeyValueModel.key, label: self.sourceMessageLBL)
                        if sourceKeyValueModel.key == targetKeyValueModel.value {
                            if let path = sourceKeyValueModel.filePath,
                                let range = sourceKeyValueModel.range {
                                var content = try? String.init(contentsOfFile: path)
                                content = ((content ?? "") as NSString).replacingOccurrences(of: sourceKeyValueModel.key, with: targetKeyValueModel.key, options: .anchored, range: range)
                                try? content?.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
                                return true
                            }
                        }
                    }
                    return false
                })
            })
            self.endExecute()
        }
    }
}

// MARK: - YQDragDropViewDelegate
extension YQMainViewController: YQDragDropViewDelegate {
    func draggingFileAccept(_ dragDropView: YQDragDropView, files: [String]) {
        if dragDropView == sourceDragDropView {
            sourceDataList.removeAll()
            files.forEach { (pathStr) in
                let fileModel = YQFileModel(filePath: pathStr)
                sourceDataList.append(fileModel)
            }
            reloadSourceTableVC()
        } else {
            targetDataList.removeAll()
            files.forEach { (pathStr) in
                let fileModel = YQFileModel(filePath: pathStr)
                targetDataList.append(fileModel)
            }
            reloadTargetTableVC()
        }
    }
}

// MARK: - 拓展功能
extension YQMainViewController {
    
    /// 1. 当目标文件的value和源文件的value不同时,是否更新目标文件的value
    /// 2. 当源文件中没有目标文件的key-value 时,是否添加
    /// - Parameter isUpdate: 是否更新
    /// - Parameter isAdd: 是否添加
    fileprivate func updateSourceFromeTarget(whenDifferentValue isUpdate: Bool = true, whenNoValue isAdd: Bool = true) {
        if !isUpdate && !isAdd {
            return;
        }
        starExecute()
        DispatchQueue.global().async {
            // 源文件key-value
            let sourceKeyValueModels = self.allKeyValueModels(self.sourceDataList)
            // 目标文件key-value
            let targetKeyValueModels = self.allKeyValueModels(self.targetDataList)
            // 待添加的key-value
            var addKeyValueModels: [KeyValueModel] = []
            
            for tarketKeyValueModel in targetKeyValueModels {
                self.showMessage("正在处理:" + tarketKeyValueModel.key, label: self.targetMessageLBL)
                var isCanAdd = true
                for sourceKeyValueModel in sourceKeyValueModels {
                    self.showMessage("正在处理:" + sourceKeyValueModel.key, label: self.sourceMessageLBL)
                    if sourceKeyValueModel.key == tarketKeyValueModel.key {
                        if sourceKeyValueModel.value != tarketKeyValueModel.value {
                            if isUpdate {
                                sourceKeyValueModel.value = tarketKeyValueModel.value
                            }
                        }
                        isCanAdd = false
                        break
                    }
                }
                if isCanAdd, isAdd {
                    addKeyValueModels.append(tarketKeyValueModel)
                }
            }
            JointManager.shared.JointForIOS(sourceKeyValueModels + addKeyValueModels)
            JointManager.shared.JointForAndroid(sourceKeyValueModels + addKeyValueModels)
            self.endExecute()
        }
    }
    
    /// 使用目标资源文件的value 作为占位词条替换 源文件的value
    fileprivate func placeholderForValue() {
        starExecute()
        DispatchQueue.global().async {
            // 德文文件
            let sourceKeyValueModels = self.allKeyValueModels(self.sourceDataList)
            // 中文文件
            let targetKeyValueModels = self.allKeyValueModels(self.targetDataList)
            for sourceKeyValueModel in sourceKeyValueModels {
                self.showMessage("正在处理:" + sourceKeyValueModel.key, label: self.sourceMessageLBL)
                if sourceKeyValueModel.value.count > 0 {
                    continue
                }
                for tarketKeyValueModel in targetKeyValueModels {
                    self.showMessage("正在处理:" + tarketKeyValueModel.key, label: self.targetMessageLBL)
                    if sourceKeyValueModel.key == tarketKeyValueModel.key {
                        sourceKeyValueModel.value = tarketKeyValueModel.value
                        break
                    }
                }
            }
            JointManager.shared.JointForIOS(sourceKeyValueModels)
            JointManager.shared.JointForAndroid(sourceKeyValueModels)
            self.endExecute()
        }
    }
}

extension YQMainViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            JointManager.shared.outFolderName = textField.stringValue
            configOutpath()
        }
    }
}
