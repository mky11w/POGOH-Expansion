import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

# List each file along with its specific feature column
file_feature_pairs = [
    ("Demographic mapping/disbility_percentage.csv", "disbility_percentage"),
    ("Demographic mapping/vehicle_pca.csv", "total_percentage"),
    ("Demographic mapping/minority_percentage.csv", "minority_percentage"),
    ("Demographic mapping/poverty_percentage.csv", "poverty_percentage")
]

# Read each file and subset to just 'GEOID' and the feature of interest
dfs = []
for file, feature in file_feature_pairs:
    df = pd.read_csv(file)
    # Ensure the file has the required columns
    if 'GEOID' not in df.columns or feature not in df.columns:
        raise ValueError(f"File {file} must contain 'GEOID' and '{feature}' columns")
    # Subset the dataframe to only include GEOID and the feature column
    dfs.append(df[['GEOID', feature]])

# Merge all DataFrames on 'GEOID'
df_merged = dfs[0]
for df in dfs[1:]:
    df_merged = df_merged.merge(df, on='GEOID', how='inner')

# Define the feature list
features = ['disbility_percentage', 'total_percentage', 'minority_percentage', 'poverty_percentage']

# Drop rows with missing values in the feature columns
df_clean = df_merged.dropna(subset=features)

# Extract the feature values and standardize them
x = df_clean[features].values
scaler = StandardScaler()
x_std = scaler.fit_transform(x)

# Perform PCA with as many components as there are features
pca = PCA(n_components=len(features))
principalComponents = pca.fit_transform(x_std)

# Create a DataFrame for the PCA results with columns named PCA1, PCA2, etc.
pca_columns = [f'PCA{i+1}' for i in range(principalComponents.shape[1])]
pca_df = pd.DataFrame(data=principalComponents, columns=pca_columns, index=df_clean.index)

# Print PCA output for inspection
print("Explained Variance Ratio:", pca.explained_variance_ratio_)
print("PCA Components (Loadings):")
print(pca.components_)

# Combine the GEOID column with the PCA results
result = pd.concat([df_clean[['GEOID']], pca_df], axis=1)

# Save the result to a CSV file
result.to_csv('result.csv', index=False)
