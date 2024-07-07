require 'csv'
require 'set'

# configurazione iniziale
REPO_URL = 'https://github.com/facebook/react.git'
REPO_PATH = 'react_repo'

# clona la repository se non esiste già
unless Dir.exist?(REPO_PATH)
  system("git clone #{REPO_URL} #{REPO_PATH}")
end

# aggiorna la repository
print "Updating repository..."
pid = Process.spawn("cd #{REPO_PATH}/react && git pull", out: File::NULL)
Process.wait(pid)
print "done.\n"

puts "\nStarting analysis of the repository at #{REPO_URL}...\n\n"

# ottieni i commit utilizzando git log
commit_log = `cd #{REPO_PATH}/react && git checkout main && git log --pretty=format:"%H|%an"`

# dividi il log in righe di commit
commits = commit_log.split("\n")

# analizza i commit
file_changes = {}
file_contributors = {}

commits.each_with_index do |commit, index|
  sha, author = commit.split('|')

  puts "Analyzing commit #{index + 1}/#{commits.size} (#{sha}) by #{author}..."

  # ottieni le informazioni sui file modificati dal commit
  commit_files = `cd #{REPO_PATH}/react && git show --pretty=format: --name-only #{sha}`.split("\n")

  commit_files.each do |file_name|
    file_changes[file_name] ||= 0
    file_changes[file_name] += 1

    file_contributors[file_name] ||= Set.new
    file_contributors[file_name].add(author)
  end
end

# ordina i file per numero di cambiamenti
sorted_files = file_changes.sort_by { |_, changes| -changes }.first(20)

# prepara i dati per il CSV
output_data = sorted_files.map do |file, changes|
  [file, changes, file_contributors[file].size, file_contributors[file].to_a.join(', ')]
end

# scrive i risultati in un file CSV
CSV.open('github_repo_analysis.csv', 'w') do |csv|
  csv << ['File', 'Total Changes', 'Number of Contributors', 'Contributors']
  output_data.each { |row| csv << row }
end

puts "\nAnalysis completed.\nResults are saved in 'github_repo_analysis.csv'."

