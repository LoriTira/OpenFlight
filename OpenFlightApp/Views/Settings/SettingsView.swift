import SwiftUI

struct SettingsView: View {
    @AppStorage(AppConstants.apiKeyDefaultsKey) private var apiKey = ""
    @State private var showingKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AviationStack API Key")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack {
                            if showingKey {
                                TextField("Paste your API key", text: $apiKey)
                                    .font(.system(.body, design: .monospaced))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            } else {
                                SecureField("Paste your API key", text: $apiKey)
                                    .font(.system(.body, design: .monospaced))
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                            }

                            Button {
                                showingKey.toggle()
                            } label: {
                                Image(systemName: showingKey ? "eye.slash" : "eye")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Flight Data")
                } footer: {
                    Text("Get a free API key at aviationstack.com (100 requests/month). Without a key, the app uses demo data.")
                }

                Section("About") {
                    LabeledContent("Version", value: "2.0")

                    Link(destination: URL(string: "https://github.com/LoriTira/OpenFlight")!) {
                        HStack {
                            Text("Source Code")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://aviationstack.com")!) {
                        HStack {
                            Text("Flight Data by AviationStack")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("OpenFlight")
                                .font(.headline)
                                .fontDesign(.rounded)
                            Text("Free Flighty Alternative")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
