Event.destroy_all

today = Date.current
statuses = Event.statuses.keys

titles = [
  "キックオフMTG", "資料提出", "デザインレビュー", "顧客訪問", "定例会議",
  "予算承認申請", "リリース作業", "採用面談", "社内勉強会", "契約更新確認",
  "月次報告作成", "システム保守", "新人研修", "経費精算", "見積作成",
  "議事録送付", "サーバーメンテナンス", "パートナー打ち合わせ", "展示会準備", "年次総会"
]

titles.each_with_index do |title, index|
  start_date = today + (index - 5).days
  Event.create!(
    title: title,
    description: "#{title}に関する対応。",
    start_date: start_date,
    end_date: index.even? ? start_date + 1.day : nil,
    status: statuses[index % statuses.size]
  )
end

puts "Created #{Event.count} events"
