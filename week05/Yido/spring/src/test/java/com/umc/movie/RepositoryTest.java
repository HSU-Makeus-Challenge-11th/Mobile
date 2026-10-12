package com.umc.movie;

import com.umc.movie.entity.Member;
import com.umc.movie.entity.Rating;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.TestPropertySource;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@TestPropertySource(properties = "spring.jpa.hibernate.ddl-auto=create-drop")
class RepositoryTest {

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private RatingRepository ratingRepository;

    @Test
    void checksNicknameAndEmailAndFindsRatingsLatestFirst() {
        Member suhyun = memberRepository.save(new Member("noco@umc.com", "dummy", "수현"));
        Member minseo = memberRepository.save(new Member("minseo@umc.com", "dummy", "민서"));
        ratingRepository.save(new Rating(suhyun, 550L, 5, "최고의 영화!"));
        ratingRepository.save(new Rating(suhyun, 155L, 4, "다시 봐도 명작"));
        ratingRepository.save(new Rating(minseo, 550L, 3, "호불호가 갈릴 것 같아요"));

        assertThat(memberRepository.existsByNickname("수현")).isTrue();
        assertThat(memberRepository.existsByNickname("없는닉네임")).isFalse();
        assertThat(memberRepository.existsByEmail("noco@umc.com")).isTrue();

        List<Rating> ratings = ratingRepository.findByMember_MemberIdOrderByRatingIdDesc(suhyun.getMemberId());
        assertThat(ratings).extracting(Rating::getMovieId).containsExactly(155L, 550L);
        assertThat(ratings.get(0).getCreatedAt()).isNotNull();
    }
}
