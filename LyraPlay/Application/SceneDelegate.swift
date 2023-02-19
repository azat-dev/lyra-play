//
//  SceneDelegate.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.06.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var application: Application!
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let settings = ApplicationSettings(
            dbFileName: "LyraPlay.sqlite",
            imagesFolderName: "mediafiles_images",
            audioFilesFolderName: "mediafiles_data",
            subtitlesFolderName: "subtitles",
            supportedSubtitlesExtensions: [".srt", ".lrc"],
            coverPlaceholderName: "Image.CoverPlaceholder",
            allowedSubtitlesDocumentTypes: ["com.azatkaiumov.subtitles"],
            allowedMediaDocumentTypes: ["public.audio"],
            defaultDictionaryArchiveName: "dictionary.lyraplay",
            dictionaryArchiveExtension: "lyraplay"
        )
        
        application = Application(
            settings: settings,
            flowModelFactory: ApplicationFlowModelImplFactory(settings: settings),
            flowPresenterFactory: ApplicationFlowPresenterImplFactory(),
            deepLinksModelFactory: DeepLinksHandlerFlowModelImplFactory(
                dictionaryArchiveExtension: settings.dictionaryArchiveExtension
            )
        )
        
        application.start(container: window)
        
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        
        guard let url = urlContexts.first?.url else {
            return
        }
        
        application.openDeepLink(url: url)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        
        // FIXME: FIX CRITICAL
        //        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

