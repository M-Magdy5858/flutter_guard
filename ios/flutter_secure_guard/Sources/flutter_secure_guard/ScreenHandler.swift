import Flutter
import UIKit

class ScreenHandler {
    // Content rendered inside a secure text field's layer is blanked by iOS
    // in screenshots and screen recordings.
    private var secureField: UITextField?
    private var isEnabled = false
    private var blurView: UIVisualEffectView?

    init() {
        // The app switcher snapshot is taken after resigning active, so
        // cover the content before that happens.
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.showBlur() }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.hideBlur() }
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableProtection": setProtection(true, result: result)
        case "disableProtection": setProtection(false, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    private func setProtection(_ enabled: Bool, result: @escaping FlutterResult) {
        guard let window = keyWindow() else {
            return result(FlutterError(code: "NO_WINDOW", message: "Screen protection requires a key window", details: nil))
        }
        let field = secureField ?? attachSecureField(to: window)
        field.isSecureTextEntry = enabled
        isEnabled = enabled
        result(nil)
    }

    private func showBlur() {
        guard isEnabled, blurView == nil, let window = keyWindow() else { return }
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blur.frame = window.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(blur)
        blurView = blur
    }

    private func hideBlur() {
        blurView?.removeFromSuperview()
        blurView = nil
    }

    // Reparents the window's layer into the secure field's canvas once;
    // afterwards toggling isSecureTextEntry is enough.
    private func attachSecureField(to window: UIWindow) -> UITextField {
        let field = UITextField()
        field.isUserInteractionEnabled = false
        window.addSubview(field)
        window.layer.superlayer?.addSublayer(field.layer)
        if #available(iOS 17.0, *) {
            field.layer.sublayers?.last?.addSublayer(window.layer)
        } else {
            field.layer.sublayers?.first?.addSublayer(window.layer)
        }
        secureField = field
        return field
    }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
            ?? UIApplication.shared.delegate?.window ?? nil
    }
}
