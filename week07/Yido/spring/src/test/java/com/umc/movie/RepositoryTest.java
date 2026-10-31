package com.umc.movie;

import com.umc.movie.entity.Member;
import com.umc.movie.entity.Rating;
import com.umc.movie.repository.MemberRepository;
import com.umc.movie.repository.RatingRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.test.context.TestPropertySource;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

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

    @Test
    void uniqueConstraintsBlockDuplicatesThatPassTheServiceCheck() {
        Member member = memberRepository.saveAndFlush(new Member("noco@umc.com", "dummy", "수현"));
        ratingRepository.saveAndFlush(new Rating(member, 550L, 5, null));

        assertThatThrownBy(() -> memberRepository.saveAndFlush(new Member("noco@umc.com", "dummy", "새닉네임")))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    void ratingUniqueConstraintBlocksSameMemberAndMovie() {
        Member member = memberRepository.saveAndFlush(new Member("minseo@umc.com", "dummy", "민서"));
        ratingRepository.saveAndFlush(new Rating(member, 550L, 5, null));

        assertThat(ratingRepository.existsByMember_MemberIdAndMovieId(member.getMemberId(), 550L)).isTrue();
        assertThatThrownBy(() -> ratingRepository.saveAndFlush(new Rating(member, 550L, 1, null)))
                .isInstanceOf(DataIntegrityViolationException.class);
    }
}
