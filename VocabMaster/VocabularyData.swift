//
//  VocabularyData.swift
//  VocabMaster
//

import Foundation

class VocabularyData {
    static func getDefaultCategories() -> [Category] {
        return [
            Category(
                id: "business",
                type: .business,
                words: [
                    VocabularyWord(
                        word: "Negotiate",
                        definition: "To discuss something in order to reach an agreement",
                        example: "We need to negotiate the terms of the contract.",
                        pronunciation: "/nɪˈɡoʊʃieɪt/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Stakeholder",
                        definition: "A person or group with an interest in a business",
                        example: "All stakeholders were invited to the meeting.",
                        pronunciation: "/ˈsteɪkhoʊldər/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Revenue",
                        definition: "Income generated from business activities",
                        example: "The company reported increased revenue this quarter.",
                        pronunciation: "/ˈrevənuː/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Collaborate",
                        definition: "To work jointly with others",
                        example: "Teams collaborate to achieve common goals.",
                        pronunciation: "/kəˈlæbəreɪt/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Leverage",
                        definition: "To use something to maximum advantage",
                        example: "We can leverage our expertise to win this contract.",
                        pronunciation: "/ˈlevərɪdʒ/",
                        language: .en,
                        translationLanguage: .en
                    )
                ]
            ),
            Category(
                id: "travel",
                type: .travel,
                words: [
                    VocabularyWord(
                        word: "Itinerary",
                        definition: "A planned route or journey schedule",
                        example: "Please review your travel itinerary carefully.",
                        pronunciation: "/aɪˈtɪnəreri/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Accommodation",
                        definition: "A place where someone can live or stay",
                        example: "We booked accommodation near the beach.",
                        pronunciation: "/əˌkɒməˈdeɪʃən/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Departure",
                        definition: "The action of leaving a place",
                        example: "The departure time is 8:00 AM.",
                        pronunciation: "/dɪˈpɑːtʃər/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Excursion",
                        definition: "A short journey for pleasure",
                        example: "We went on a day excursion to the mountains.",
                        pronunciation: "/ɪkˈskɜːrʒən/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Customs",
                        definition: "Government agency controlling imports/exports",
                        example: "You must go through customs at the airport.",
                        pronunciation: "/ˈkʌstəmz/",
                        language: .en,
                        translationLanguage: .en
                    )
                ]
            ),
            Category(
                id: "daily",
                type: .daily,
                words: [
                    VocabularyWord(
                        word: "Appreciate",
                        definition: "To recognize the value of something",
                        example: "I really appreciate your help with this.",
                        pronunciation: "/əˈpriːʃieɪt/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Convince",
                        definition: "To persuade someone to do or believe something",
                        example: "She tried to convince me to join the club.",
                        pronunciation: "/kənˈvɪns/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Exhausted",
                        definition: "Extremely tired",
                        example: "I was exhausted after the long day.",
                        pronunciation: "/ɪɡˈzɔːstɪd/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Recommend",
                        definition: "To suggest something as good or suitable",
                        example: "Can you recommend a good restaurant?",
                        pronunciation: "/ˌrekəˈmend/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Hesitate",
                        definition: "To pause before doing something",
                        example: "Don't hesitate to call if you need anything.",
                        pronunciation: "/ˈhezɪteɪt/",
                        language: .en,
                        translationLanguage: .en
                    )
                ]
            ),
            Category(
                id: "academic",
                type: .academic,
                words: [
                    VocabularyWord(
                        word: "Hypothesis",
                        definition: "A proposed explanation based on limited evidence",
                        example: "The scientist tested her hypothesis through experiments.",
                        pronunciation: "/haɪˈpɒθəsɪs/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Analyze",
                        definition: "To examine something in detail",
                        example: "Students must analyze the text carefully.",
                        pronunciation: "/ˈænəlaɪz/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Synthesize",
                        definition: "To combine different ideas into a coherent whole",
                        example: "The essay should synthesize multiple perspectives.",
                        pronunciation: "/ˈsɪnθəsaɪz/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Methodology",
                        definition: "A system of methods used in a study",
                        example: "The research methodology was clearly explained.",
                        pronunciation: "/ˌmeθəˈdɒlədʒi/",
                        language: .en,
                        translationLanguage: .en
                    ),
                    VocabularyWord(
                        word: "Abstract",
                        definition: "A summary of a research paper or article",
                        example: "Read the abstract before the full paper.",
                        pronunciation: "/ˈæbstrækt/",
                        language: .en,
                        translationLanguage: .en
                    )
                ]
            )
        ]
    }
}
