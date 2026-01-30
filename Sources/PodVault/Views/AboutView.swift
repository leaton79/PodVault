import SwiftUI

/// About window showing app information
struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            // App icon
            Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            // App name and version
            VStack(spacing: 4) {
                Text("PodVault")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Description
            Text("A desktop podcast listening and downloading app")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
                .frame(width: 200)
            
            // Links
            VStack(spacing: 8) {
                Link("GitHub Repository", destination: URL(string: "https://github.com/leaton79/PodVault")!)
                Link("Report an Issue", destination: URL(string: "https://github.com/leaton79/PodVault/issues")!)
            }
            .font(.callout)
            
            Divider()
                .frame(width: 200)
            
            // Credits
            VStack(spacing: 4) {
                Text("Built with Swift & SwiftUI")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("License: GNU GPL v3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Copyright
            Text("© 2026 Lance Eaton")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(40)
        .frame(width: 350, height: 450)
    }
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
